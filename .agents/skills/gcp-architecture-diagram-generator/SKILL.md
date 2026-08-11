---
name: gcp-architecture-diagram-generator
description: >-
  Inspects the terraform/ directory and deployment scripts, generates a high-resolution
  GCP architecture diagram image using generate_image, updates assets/gcp_architecture_diagram.png,
  updates the README.md Architecture section, and creates a comprehensive gcp_architecture_diagram.md artifact.
---

# GCP Architecture Diagram Generator

This skill automates the end-to-end process of inspecting Terraform configurations, generating a visual GCP architecture diagram image, storing the asset in the repository, and updating documentation across `README.md` and artifact reports.

---

## Trigger Conditions

Activate this skill whenever the user asks to:
- *"Update the architecture diagram"*
- *"Refresh the GCP architecture diagram based on terraform changes"*
- *"Generate an architecture diagram for terraform/"*
- *"Re-render the GCP diagram image"*

---

## Workflow Steps

### Step 1: Infrastructure Inspection
1. Read and analyze all `.tf` files in `terraform/`:
   - `main.tf` (VPC networks, subnetworks, firewall rules, GCE instances, disks, IP reservations)
   - `storage.tf` & `versions.tf` (GCS remote backend state bucket, versioning, location)
   - `wif.tf` & `api.tf` (Workload Identity Federation, Service Accounts, GCP APIs)
   - `colab.tf` (Vertex AI / Colab Enterprise runtimes)
   - `variables.tf` & `outputs.tf` (Input variables and outputs)
2. Read startup scripts in `terraform/scripts/` (e.g., `startup-script.sh`) to capture automated formatting, mount points, and cluster initialization logic (e.g., MongoDB `rs-analytics` replica set initiation).
3. Read orchestration files (`Makefile`, `.github/workflows/`) to understand deployment triggers.

---

### Step 2: Diagram Image Generation
Invoke the `generate_image` tool to render a high-resolution architecture diagram image:

- **Image Name**: `gcp_architecture_diagram`
- **Aspect Ratio**: `'16:9'`
- **Sanitization Rules**:
  - Replace any project-specific names (e.g., specific GCP project IDs) with generic variable placeholders (`var.gcp_project_id`).
  - Replace hardcoded state bucket names with `gs://var.tfstate_bucket_name`.
- **Prompt Requirements**:
  - Clear top-level box for `GCP Organization / Project 'var.gcp_project_id'`.
  - Top-left box for CI/CD authentication (GitHub Actions, Workload Identity Federation, Service Account `codemender-sa`).
  - Top-right box for `GCS Remote State Bucket gs://var.tfstate_bucket_name`.
  - Regional custom VPC box (`mongodb-network`) containing subnet (`mongodb-subnet 10.42.0.0/24`).
  - Internal Firewall rules (IAP SSH Port 22, Replication Port 27017).
  - 3 Availability Zone boxes (`us-central1-a`, `us-central1-b`, `us-central1-c`) with Compute Engine VM instances (`mongodb-1`, `mongodb-2`, `mongodb-3`) and attached `1000GB pd-ssd` persistent data disks.
  - Multi-zone replication links indicating the MongoDB replica set (`rs-analytics`).
  - Vertex AI / Colab Enterprise runtime node (`mongodb-data-gen-runtime`) connected inside the subnet.

---

### Step 3: Asset Storage
1. Ensure the `assets/` directory exists at the repository root.
2. Copy or save the generated image to `assets/gcp_architecture_diagram.png`.

---

### Step 4: README.md Update
1. Inspect the repository `README.md` file.
2. Locate the `## 🏗️ Architecture` section.
3. Place the architecture diagram image link directly under the `## 🏗️ Architecture` heading before any text or Mermaid diagrams:
   ```markdown
   ## 🏗️ Architecture

   ![GCP Architecture Diagram](assets/gcp_architecture_diagram.png)
   ```

---

### Step 5: Standalone Artifact Generation
1. Create or update the artifact `gcp_architecture_diagram.md` in the current conversation's artifact directory.
2. Include:
   - Visual GCP Architecture Diagram image embed.
   - Interactive Mermaid flowchart detailing the full network & IAM hierarchy.
   - Mermaid sequence diagram showing the multi-phase deployment lifecycle (OIDC Auth -> State Init -> Provisioning -> Self-Clustering).
   - Detailed mapping table linking each `.tf` file to its provisioned GCP resources.
   - Key architectural & security design principles (Multi-zone HA, Keyless WIF authentication, IAP-only SSH ingress).

---

## Guidelines & Best Practices

- **Never Hardcode Project IDs**: Always sanitize diagrams to use parameterized variable names (`var.gcp_project_id`, `var.tfstate_bucket_name`).
- **Keep Assets Versioned**: Ensure `assets/gcp_architecture_diagram.png` is committed into source control alongside code updates.
- **Maintain Consistency**: Keep `README.md` and `gcp_architecture_diagram.md` in sync whenever terraform changes occur.
