locals {
  nat_gateway_quantity = var.create_nat ? (var.nat_gateway_high_availability ? var.number_of_azs : 1) : 0
}
