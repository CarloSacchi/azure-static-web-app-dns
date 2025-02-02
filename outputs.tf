# Development Static Web App URL
output "dev_static_web_app_url" {
  value = azurerm_static_web_app.web_dev.default_host_name
}

# Production Static Web App URL
output "prod_static_web_app_url" {
  value = azurerm_static_web_app.web_prod.default_host_name
}

# Development Custom Domain
output "dev_custom_domain" {
  value = "dev.${var.domain_name}"
}

# Production Custom Domains
output "prod_www_domain" {
  value = "www.${var.domain_name}"
}

output "prod_wildcard_domain" {
  value = "*.${var.domain_name}"
}

# DNS Zone Name Servers
output "name_servers" {
  value = azurerm_dns_zone.domain.name_servers
}