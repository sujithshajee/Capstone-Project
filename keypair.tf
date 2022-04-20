####################################################################################################
# Generate key pair for ec2 instances
####################################################################################################
# SubTask-4
resource "tls_private_key" "terraform-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.KEY_NAME
  public_key = tls_private_key.terraform-key.public_key_openssh

  # Generate "terraform-key-pair.pem" in current directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terraform-key.private_key_pem}' > ./'${var.KEY_NAME}'.pem
      chmod 400 ./'${var.KEY_NAME}'.pem
    EOT
  }
}

