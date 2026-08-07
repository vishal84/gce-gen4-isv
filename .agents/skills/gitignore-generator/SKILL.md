---
name: gitignore-generator
description: |
  Generates, audits, and maintains comprehensive, battle-tested .gitignore and cloud ignore files (.gcloudignore, .dockerignore) for any tech stack.
  Use this skill whenever:
    1. Creating or upgrading a .gitignore file for a repository.
    2. Preventing accidental commits of cloud secrets, API keys, service account JSON credentials, and local environment configs.
    3. Configuring ignore rules for Google Cloud, Terraform, Docker, Python, Node.js, and IDE environments.
    4. Setting up .gcloudignore or cloud configuration management files.
license: Apache-2.0
metadata:
  version: v1.0.0
  publisher: antigravity-community
---

# Gitignore & Cloud Ignore Generator Skill

This skill provides comprehensive rules, security patterns, and ready-to-use templates for generating clean, secure, and bulletproof `.gitignore`, `.gcloudignore`, and configuration management files.

---

## 🛡️ Core Rules & Security Principles

1. **Zero Cloud Secrets**: NEVER allow service account keys (`*.json`, `*sa*.json`), Google Application Default Credentials (`application_default_credentials.json`), PEM/P12 certificates, or `.env` files into source control.
2. **Infrastructure as Code Hygiene**: Always ignore Terraform state files (`*.tfstate`, `*.tfstate.*`, `.terraform/`, `*.tfvars` containing secrets), lock file temp backups, and crash logs.
3. **Multi-Environment Coverage**: Include rules for local operating systems (macOS `.DS_Store`, Windows `Thumbs.db`, Linux temp files), IDEs (VS Code `.vscode/`, JetBrains `.idea/`), and cloud tooling caches.
4. **Complement with `.gcloudignore`**: When using Google Cloud SDK / Cloud Build / Cloud Functions / App Engine, maintain a dedicated `.gcloudignore` to prevent uploading unnecessary files and sensitive data during deployments.

---

## 📑 Ignore Rule Catalog & Templates

### 1. Google Cloud Specific Rules
```gitignore
# ==========================================
# Google Cloud Platform (GCP) & Credentials
# ==========================================
# Service account private keys & credentials
*credentials*.json
*service_account*.json
*service-account*.json
*sa-key*.json
gcp-key*.json
application_default_credentials.json

# Cloud SDK runtime caches & state
.gcloud/
.gcloudignore.bk
credentials.db
access_tokens.db

# Cloud Code / Cloud Tools
.cloudcode/
```

### 2. Terraform & Infrastructure as Code Rules
```gitignore
# ==========================================
# HashiCorp Terraform
# ==========================================
# Local .terraform directories and plugin caches
**/.terraform/*
.terraform/
.terraform.lock.hcl.tmp

# Terraform state files & backups
*.tfstate
*.tfstate.*
*.tfstate.backup

# Sensitive variable files (allow example templates)
*.tfvars
*.tfvars.json
*.auto.tfvars
*.auto.tfvars.json
!example.tfvars
!*.example.tfvars
!config.tfvars.example

# Crash logs and CLI plan outputs
crash.log
crash.*.log
*.tfplan
*.tfplan.binary
```

### 3. Operating System & Editor Artifacts
```gitignore
# ==========================================
# Operating System & IDEs
# ==========================================
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# Linux
*~
.directory

# Visual Studio Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# JetBrains / IntelliJ / PyCharm
.idea/
*.iml
*.iws
```

---

## ☁️ Google Cloud Configuration Management

In addition to `.gitignore`, maintain Google Cloud configuration management files:

1. **`.gcloudignore`**: Controls which files `gcloud` uploads during Cloud Build, App Engine deployments, or GCS operations.
2. **`gcp-config.yaml` / `env.gcp.example`**: Provides declarative, version-controlled metadata for managing GCP project configurations, regions, and service definitions without checking in secrets.

---

## 🔄 Step-by-Step Workflow

1. **Audit Workspace Stack**: Detect languages, cloud platforms (GCP, AWS, Azure), and IaC tools (Terraform, Pulumi, Kubernetes).
2. **Identify Sensitive Files**: Check for `*.json` service keys, `.env` files, `.tfvars`, or credentials.
3. **Assemble Tailored `.gitignore`**: Combine language, cloud, IaC, and OS modules into a clean, well-commented file.
4. **Generate Cloud Config & `.gcloudignore`**: Provide corresponding cloud management files to support developer workflows.
5. **Verify Untracked State**: Run `git status` or inspect staging to ensure sensitive files remain untracked.
