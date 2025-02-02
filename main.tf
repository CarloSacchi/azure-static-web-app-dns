resource "azurerm_resource_group" "rg" {
  name     = format("rg-%s", var.project_name)
  location = var.location
  tags     = var.tags
}

resource "azurerm_dns_zone" "domain" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "5m"
  }
}

# Development Static Web App
resource "azurerm_static_web_app" "web_dev" {
  name                = format("swa-d-%s", var.project_name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
    read   = "5m"
  }
}

# Production Static Web App
resource "azurerm_static_web_app" "web_prod" {
  name                = format("swa-p-%s", var.project_name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
    read   = "5m"
  }
}

# DNS Records
resource "azurerm_dns_cname_record" "dev" {
  name                = "dev"
  zone_name           = azurerm_dns_zone.domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = azurerm_static_web_app.web_dev.default_host_name

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "5m"
  }
}

resource "azurerm_dns_cname_record" "prod" {
  name                = "www"
  zone_name           = azurerm_dns_zone.domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record              = azurerm_static_web_app.web_prod.default_host_name

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "5m"
  }
}

# For apex domain
resource "azurerm_dns_a_record" "prod_apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  target_resource_id  = azurerm_static_web_app.web_prod.id

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "5m"
  }
}

# Add delay for DNS propagation
resource "time_sleep" "wait_for_dns" {
  depends_on = [
    azurerm_dns_cname_record.dev,
    azurerm_dns_cname_record.prod,
    azurerm_dns_a_record.prod_apex
  ]
  create_duration = "90s"
}

# Custom Domains
resource "azurerm_static_web_app_custom_domain" "dev" {
  static_web_app_id = azurerm_static_web_app.web_dev.id
  domain_name       = "dev.${var.domain_name}"
  validation_type   = "dns-txt-token"

  depends_on = [time_sleep.wait_for_dns]

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "5m"
  }
}

resource "azurerm_static_web_app_custom_domain" "prod_www" {
  static_web_app_id = azurerm_static_web_app.web_prod.id
  domain_name       = "www.${var.domain_name}"
  validation_type   = "dns-txt-token"

  depends_on = [time_sleep.wait_for_dns]

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "5m"
  }
}

resource "azurerm_static_web_app_custom_domain" "prod_apex" {
  static_web_app_id = azurerm_static_web_app.web_prod.id
  domain_name       = var.domain_name # apex domain
  validation_type   = "dns-txt-token"

  depends_on = [time_sleep.wait_for_dns]

  timeouts {
    create = "30m"
    delete = "30m"
    read   = "5m"
  }
}

# DNS Validation Records
resource "azurerm_dns_txt_record" "validation" {
  for_each = {
    "dev" = azurerm_static_web_app_custom_domain.dev.validation_token
    "www" = azurerm_static_web_app_custom_domain.prod_www.validation_token
    "@"   = azurerm_static_web_app_custom_domain.prod_apex.validation_token
  }
  name                = each.key == "@" ? "_dnsauth" : "_dnsauth.${each.key}"
  zone_name           = azurerm_dns_zone.domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  record {
    value = each.value
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
    read   = "5m"
  }
}