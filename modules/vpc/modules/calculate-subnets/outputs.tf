output "calculated_subnets_map" {
  description = "Mapa com os nomes das subnets e seus blocos CIDR calculados dinamicamente."
  value       = local.calculated_subnets
}

output "utilized_azs" {
  description = "Lista de AZs utilizadas"
  value       = local.selected_azs
}