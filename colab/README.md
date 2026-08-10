# Synthetic Data Generator Notebook for MongoDB Cluster

This directory contains the [`generate_mongodb_data.ipynb`](generate_mongodb_data.ipynb) Jupyter notebook, which generates and ingests synthetic MongoDB datasets into the multi-zone replica set cluster (`rs-analytics`) provisioned by Terraform in this repository.

---

## 📊 Generated Collections & Datasets

The notebook populates the `ecommerce_analytics` database with four interconnected collections:

1. **`customers`**: User profiles with unique identifiers, contact information, geographic addresses, account tiers, and registration dates.
2. **`products`**: E-commerce catalog items with categories, SKU numbers, pricing, and stock inventory metrics.
3. **`orders`**: Transactional purchasing records linking customers and products with item breakdowns, pricing calculations (subtotal, tax, shipping), and payment statuses.
4. **`sensor_telemetry`**: Time-series IoT/infrastructure telemetry events containing CPU utilization, memory usage, system temperatures, and disk IOPS across cluster zones (`us-central1-a`, `us-central1-b`, `us-central1-c`).

---

## 🚀 Execution Guide

### Option 1: Running in Google Cloud Colab Enterprise (Recommended)

When `enable_colab_runtime = true` is set in Terraform, a **Colab Enterprise Runtime Template** is automatically provisioned inside the `mongodb-network` VPC and `mongodb-subnet` (`10.42.0.0/24`).

1. Open the [Google Cloud Console -> Vertex AI -> Colab Enterprise](https://console.cloud.google.com/vertex-ai/colab).
2. Create a new notebook or import [`generate_mongodb_data.ipynb`](generate_mongodb_data.ipynb).
3. Connect the notebook to the **`mongodb-data-gen-template`** runtime template (or `mongodb-data-gen-runtime` instance).
4. Run all notebook cells. Because the Colab runtime resides within the same VPC network (`mongodb-network`), it connects directly to internal IPs (`10.42.0.2`, `10.42.0.3`, `10.42.0.4`) on port `27017`.

---

### Option 2: Running Locally or standard Jupyter

If running locally on a machine with network access (or SSH tunnel / VPN / IAP port forwarding):

```bash
# Set environment variables if needed
export MONGODB_NODE_IPS="10.42.0.2,10.42.0.3,10.42.0.4"
export MONGODB_REPLICA_SET="rs-analytics"

# Launch Jupyter
jupyter notebook colab/generate_mongodb_data.ipynb
```

---

## ⚙️ Environment Variables Reference

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `MONGODB_NODE_IPS` | `10.42.0.2,10.42.0.3,10.42.0.4` | Comma-separated internal IP addresses of cluster nodes |
| `MONGODB_PORT` | `27017` | MongoDB service port |
| `MONGODB_REPLICA_SET` | `rs-analytics` | Target replica set name |
| `MONGODB_DATABASE` | `ecommerce_analytics` | Target database for data population |
