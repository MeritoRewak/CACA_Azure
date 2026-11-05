# 1. Configure required provider plugins and versions
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.0"
    }
  }
}

# 2. Declare input variables (Terraform automatically reads values from terraform.tfvars)
variable "render_api_key" {
  type        = string
  description = "API Key used to authenticate with the Render API"
  sensitive   = true
}

variable "render_owner_id" {
  type        = string
  description = "The Owner or Organization ID in Render"
}

# 3. Initialize the Render provider using the variables
provider "render" {
  api_key  = var.render_api_key
  owner_id = var.render_owner_id
}

# 4. Provision a managed PostgreSQL database
resource "render_postgres" "db" {
  name    = "pizzawsb-db2"
  plan    = "free"
  version = "15"
  region  = "frankfurt"
}

# 5. Provision a containerized Web Service
resource "render_web_service" "app" {
  name   = "pizzawsb-app2"
  plan   = "free"
  region = "frankfurt"

  # Define runtime source as native Docker container
  runtime_source = {
    native_docker = {}
  }

  # Environment variables injected into the web application
  env_vars = {
    DATABASE_URL = render_postgres.db.connection_string
  }
}

# 6. Output blocks to retrieve critical connection details and URLs
output "database_internal_url" {
  value     = render_postgres.db.connection_string
  sensitive = true
}

output "deploy_hook_url" {
  value     = render_web_service.app.deploy_hook_url
  sensitive = true
}

output "service_url" {
  value = render_web_service.app.url
}