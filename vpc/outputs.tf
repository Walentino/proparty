# --- vpc/outputs.tf ---

output "vpc_id" {
    value = aws_vpc.fbn_vpc.id
  
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}

