####################################################################################################
# Output:
#     public IP of bastion server
#     VPC ID
#     Subnet ID for public subnet
####################################################################################################

output "bastion-instance-public-ip" {
  description = "The public IP of bastion server"
  value       = aws_instance.bastion-instance.*.public_ip[0]
}

output "bastion-instance-private-ip" {
  description = "The private IP of bastion server"
  value       = aws_instance.bastion-instance.*.private_ip[0]
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_1" {
  description = "The ID of the public subnet 1"
  value       = aws_subnet.main-public-1.id
}

output "public_subnet_2" {
  description = "The ID of the public subnet 2"
  value       = aws_subnet.main-public-2.id
}

output "private_subnet_1" {
  description = "The ID of the private subnet 1"
  value       = aws_subnet.main-private-1.id
}

output "private_subnet_2" {
  description = "The ID of the private subnet 2"
  value       = aws_subnet.main-private-2.id
}

output "repository_name" {
  description = "Name of repository created"
  value       = aws_ecr_repository.capstoneassignment.name
}

output "repository_url" {
  description = "URL of first repository created"
  value       = aws_ecr_repository.capstoneassignment.repository_url
}