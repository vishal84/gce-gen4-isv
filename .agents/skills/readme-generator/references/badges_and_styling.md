# README Badges and Visual Styling Guide

This guide provides templates and standards for badges, layout tricks, visual components, and collapsible sections.

---

## 🛡️ Shields.io Badges

Use flat-square or for-the-badge style consistently.

### 1. Build & Release
```markdown
[![CI / Build Status](https://img.shields.io/github/actions/workflow/status/<USER>/<REPO>/ci.yml?branch=main&style=flat-square)](https://github.com/<USER>/<REPO>/actions)
[![Latest Release](https://img.shields.io/github/v/release/<USER>/<REPO>?style=flat-square&color=blue)](https://github.com/<USER>/<REPO>/releases)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
```

### 2. Tech Stack & Tools
```markdown
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FBA?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-GCP-4285F4?style=flat-square&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=flat-square&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
```

### 3. Code Quality & Coverage
```markdown
[![Coverage Status](https://img.shields.io/codecov/c/github/<USER>/<REPO>?style=flat-square)](https://codecov.io/gh/<USER>/<REPO>)
[![Code Style: Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg?style=flat-square)](https://github.com/astral-sh/ruff)
[![Prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://prettier.io)
```

---

## 📐 Mermaid Architecture Diagrams

Always use Mermaid for visual clarity without external binary dependencies.

### Example: Cloud / Infrastructure Topology
```mermaid
graph TD
    User([User / Client]) -->|HTTPS| LB[Cloud Load Balancer]
    LB --> VPC[VPC Network]
    
    subgraph VPC [VPC Network: custom-vpc]
        direction TB
        subgraph PublicSubnet [Public Subnet - us-central1]
            NAT[Cloud NAT Gateway]
        end
        subgraph PrivateSubnet [Private Subnet - us-central1]
            GCE1[GCE Instance: Primary]
            GCE2[GCE Instance: Standby]
        end
    end
    
    PrivateSubnet -->|Egress via NAT| Internet([External APIs])
    PrivateSubnet -->|Private Google Access| GCS[(Cloud Storage Bucket)]
```

---

## 🗂️ Collapsible Sections (`<details>`)

Use `<details>` tags for long logs, extensive configuration variable tables, troubleshooting sections, or advanced setups to keep the main README clean and scannable.

```html
<details>
<summary><b>🔍 View Detailed Terraform Variable Reference</b></summary>

| Name | Type | Default | Description |
|---|---|---|---|
| `project_id` | `string` | - | The GCP Project ID |
| `region` | `string` | `"us-central1"` | Target deployment region |
| `machine_type` | `string` | `"e2-standard-4"` | Compute Engine machine specification |

</details>
```

---

## 📊 Standard Tables

Use clear alignment markers (`:---` left, `:---:` center, `---:` right):

```markdown
| Component | Technology | Version | Purpose |
| :--- | :--- | :---: | :--- |
| **Compute** | Google Compute Engine | Gen4 | High performance workload execution |
| **IaC** | HashiCorp Terraform | `>= 1.5` | Declarative cloud resource provisioning |
| **Networking** | Google Cloud VPC | Subnetted | Isolated private network communication |
```
