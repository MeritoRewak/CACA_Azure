# 1. Provider
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.0" # sprawdź aktualną wersję w rejestrze
    }
  }
}

# 2. Zmienne
variable "render_api_key" {
  type        = string
  description = "API Key used to authenticate with the Render API"
  sensitive   = true
}

variable "render_owner_id" {
  type        = string
  description = "The Owner or Organization ID in Render"
}

# 3. Provider Render
provider "render" {
  api_key  = var.render_api_key
  owner_id = var.render_owner_id
}

# 4. Baza PostgreSQL
resource "render_postgres" "db" {
  name    = "wsbpizza-pgdb2"
  plan    = "free"
  version = "15"
  region  = "frankfurt"
}

# 5. Web Service uruchamiany z obrazu zbudowanego w GitHub Actions (GHCR)
resource "render_web_service" "app" {
  name   = "pizzawsb-app2"
  plan   = "free"
  region = "frankfurt"

  runtime_source = {
    image = {
      image_url = "ghcr.io/meritorewak/caca_azure" # tylko małe litery
      tag       = "latest"
      # Dla prywatnego pakietu GHCR dodaj registry_credential_id
      # (zasób render_registry_credential) - sprawdź schemat w dokumentacji.
    }
  }

  env_vars = {
    DATABASE_URL = {
      value = replace(
        render_postgres.db.connection_info.internal_connection_string,
        "/^postgres(ql)?:/",
        "postgresql+psycopg:"
      )
    }
    PORT = {
      value = "5000"
    }
  }
}

# 6. Outputy
output "service_id" {
  description = "ID usługi - użyj jako sekretu RENDER_SERVICE_ID w GitHub Actions"
  value       = render_web_service.app.id
}

output "service_url" {
  value = render_web_service.app.url
}

output "database_internal_url" {
  value     = render_postgres.db.connection_info.internal_connection_string
  sensitive = true
}

output "database_external_url" {
  value     = render_postgres.db.connection_info.external_connection_string
  sensitive = true
}