output "prod_url_linux" {
  value = "https://${module.web_app.prod_name_linux}.azurewebsites.net"
}

output "slot_1_url_linux" {
  value = "https://${module.web_app.prod_name_linux}-${module.web_app.slot_1_name_linux}.azurewebsites.net"
}

output "prod_url_windows" {
  value = "https://${module.web_app.prod_name_windows}.azurewebsites.net"
}

output "slot_1_url_windows" {
  value = "https://${module.web_app.prod_name_windows}-${module.web_app.slot_1_name_windows}.azurewebsites.net"
}
