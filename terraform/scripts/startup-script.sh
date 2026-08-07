#!/usr/bin/env bash
set -euo pipefail

exec > >(tee -a /var/log/mongo-autoscale-startup.log) 2>&1
echo "=== Starting Automated MongoDB Node Initialization ==="

# 1. Fetch Metadata Variables
MY_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
SEED_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/mongo-seed-ip || true)

if [ -z "${SEED_IP}" ]; then
  echo "ERROR: mongo-seed-ip metadata attribute is required."
  exit 1
fi

# 2. Install filesystem tooling and standardize OS drivers (NVMe & gVNIC)
apt-get update -y
apt-get install -y xfsprogs

echo "Configuring NVMe drivers in initramfs..."
if command -v dracut &> /dev/null; then
  echo 'add_dracutmodules+=" nvme nvme-core "' > /etc/dracut.conf.d/10-nvme.conf
  dracut --force --regenerate-all
elif command -v update-initramfs &> /dev/null; then
  grep -qxF "nvme" /etc/initramfs-tools/modules || echo "nvme" >> /etc/initramfs-tools/modules
  grep -qxF "nvme_core" /etc/initramfs-tools/modules || echo "nvme_core" >> /etc/initramfs-tools/modules
  update-initramfs -u -k all
fi

# 3. Format and Mount Persistent NVMe Data Disk
DATA_DEV=""
for dev in /dev/nvme*n1 /dev/sdb; do
  if [ -b "$dev" ] && [ "$dev" != "/dev/nvme0n1" ] && [ "$dev" != "/dev/sda" ]; then
    DATA_DEV="$dev"
    break
  fi
done

if [ -n "${DATA_DEV}" ]; then
  echo "Formatting persistent data disk: ${DATA_DEV}"
  if ! blkid "${DATA_DEV}"; then
    mkfs.xfs -f -m crc=1 -i size=512 "${DATA_DEV}"
  fi
  mkdir -p /var/lib/mongodb
  DATA_UUID=$(blkid -s UUID -o value "${DATA_DEV}")
  if ! grep -q "${DATA_UUID}" /etc/fstab; then
    echo "UUID=${DATA_UUID} /var/lib/mongodb xfs defaults,noatime,nodiratime 0 2" >> /etc/fstab
  fi
  mount -a
fi

# 4. Install MongoDB 7.0
if ! command -v mongod &> /dev/null; then
  echo "Installing MongoDB 7.0 Community Edition..."
  apt-get install -y gnupg curl
  curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
  apt-get update -y
  apt-get install -y mongodb-org
fi

mkdir -p /var/lib/mongodb /var/log/mongodb
chown -R mongodb:mongodb /var/lib/mongodb /var/log/mongodb

# 5. Configure mongod.conf
cat <<EOF > /etc/mongod.conf
storage:
  dbPath: /var/lib/mongodb
  engine: wiredTiger
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 0.0.0.0
replication:
  replSetName: "rs-analytics"
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

systemctl daemon-reload
systemctl restart mongod
systemctl enable mongod

# 6. Self-Registration / Replica Set Clustering Logic
echo "Waiting for local MongoDB service to accept connections..."
until mongosh --port 27017 --eval "db.adminCommand('ping')" &>/dev/null; do
  sleep 2
done

if [ "${MY_IP}" == "${SEED_IP}" ]; then
  echo "Node IP matches SEED_IP (${MY_IP}). Initializing replica set..."
  mongosh --port 27017 --eval '
    try {
      var status = rs.status();
      print("Replica set already initialized.");
    } catch(e) {
      rs.initiate({
        _id: "rs-analytics",
        members: [{ _id: 0, host: "'"${MY_IP}"':27017", priority: 2 }]
      });
      print("Replica set initiated successfully.");
    }
  '
else
  echo "Node IP (${MY_IP}) is a worker. Waiting for Primary (${SEED_IP}) to become reachable..."
  until mongosh --host "${SEED_IP}:27017" --eval "db.adminCommand('ping')" &>/dev/null; do
    echo "Waiting for primary node at ${SEED_IP}:27017..."
    sleep 5
  done

  echo "Attempting self-registration with Primary (${SEED_IP})..."
  mongosh --host "${SEED_IP}:27017" --eval '
    var status = rs.status();
    var isMember = false;
    for (var i = 0; i < status.members.length; i++) {
      if (status.members[i].name === "'"${MY_IP}"':27017") {
        isMember = true;
        break;
      }
    }
    if (!isMember) {
      rs.add({ host: "'"${MY_IP}"':27017", priority: 1 });
      print("Successfully added host '"${MY_IP}"':27017 to replica set.");
    } else {
      print("Host '"${MY_IP}"':27017 is already a member of the replica set.");
    }
  '
fi

echo "=== MongoDB Node Initialization Complete ==="