####################################################################################################
# get self IP address
####################################################################################################

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

output "local_public_ip" {
  value = data.external.myipaddr.result.ip
}

####################################################################################################
# bastion SG with ingress from self ip and all egress
####################################################################################################

resource "aws_security_group" "bastion-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "bastion-sg"
  description = "security group for bastion"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.myipaddr.result.ip}/32"]
  }
}