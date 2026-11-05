
# ==========================================
# 1. Terraform Provider
# ==========================================

terraform {
  required_version = ">= 1.9.1"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.0"
    }
  }
}

# ==========================================
# 2. Variables
# ==========================================

variable "render_api_key" {
  type        = string
  description = "Render API Key"
  sensitive   = true
}

variable "render_owner_id" {
  type        = string
  description = "Render Owner or Organization ID"
}

# ==========================================
# 3. Render Provider
# ==========================================

provider "render" {
  api_key  = var.render_api_key
  owner_id = var.render_owner_id
}

# ==========================================
# 4. PostgreSQL Database
# ==========================================

resource "render_postgres" "db" {
  name    = "wsbpizza-pgdb"
  plan    = "free"
  version = "18"
  region  = "frankfurt"
}

# ==========================================
# 5. Web Service - Docker Image from GHCR
# ==========================================

resource "render_web_service" "app" {
  name   = "pizzawsb-app"
  plan   = "free"
  region = "frankfurt"

  runtime_source = {
    image = {
      image_url = "ghcr.io/meritorewak/caca_azure"
      tag       = "latest"
    }
  }

  env_vars = {
    # SQLAlchemy + psycopg2-binary==2.9.9
    DATABASE_URL = {
      value = replace(
        render_postgres.db.connection_info.internal_connection_string,
        "/^postgres(ql)?:/",
        "postgresql+psycopg2:"
      )
    }

    PORT = {
      value = "5000"
    }
  }
}

# ==========================================
# 6. Outputs
# ==========================================

output "service_id" {
  description = "Render Web Service ID - GitHub Actions"
  value       = render_web_service.app.id
}

output "service_url" {
  description = "Public application URL"
  value       = render_web_service.app.url
}

output "database_internal_url" {
  description = "Internal PostgreSQL URL"
  value       = render_postgres.db.connection_info.internal_connection_string
  sensitive   = true
}

output "database_external_url" {
  description = "External PostgreSQL URL"
  value       = render_postgres.db.connection_info.external_connection_string
  sensitive   = true
}
