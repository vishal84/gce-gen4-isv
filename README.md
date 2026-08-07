# Three-node MongoDB cluster

This Terraform configuration creates a three-node MongoDB 7.0 replica set in
`us-central1`, placing one `n2-standard-8` VM in each of
`us-central1-a`, `us-central1-b`, and `us-central1-c`.

Each VM is created from the shared instance template and executes
[`terraform/scripts/startup-script.sh`](terraform/scripts/startup-script.sh). Terraform reserves
the nodes' internal IP addresses before the VMs are created and passes the
first address to every node as `mongo-seed-ip`, so the seed initializes the
replica set and the other nodes register themselves without post-deployment
configuration.

The configuration uses the project and credentials from the active Google
Application Default Credentials or gcloud configuration; it does not require
Terraform variables or an environment file. The deploying identity must have
permission to enable Compute Engine and create the listed Compute Engine
resources.

```sh
cd terraform
terraform init
terraform apply
```

The data disks are independently managed 500 GB SSD persistent disks. MongoDB
traffic is permitted only within the dedicated `10.42.0.0/24` subnet. Nodes
have external egress addresses solely to install operating-system and MongoDB
packages; no external MongoDB ingress rule is created.
