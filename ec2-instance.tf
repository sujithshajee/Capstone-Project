####################################################################################################
# provision bastion instance with provided AMI and region
####################################################################################################
resource "aws_instance" "bastion-instance" {
  ami                    = var.AMIS["bastion"]
  instance_type          = "t2.micro"
  key_name               = var.KEY_NAME
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id              = aws_subnet.main-public-1.id

  tags = {
    Name = "bastion-instance"
  }

  provisioner "file" {
    source      = "${var.KEY_NAME}.pem"
    destination = "/tmp/${var.KEY_NAME}.pem"
  }

  # Task 2 - SubTask-1
  provisioner "file" {
    source      = "./scripts/task-0-environment-setup.sh"
    destination = "/tmp/task-0-environment-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /tmp/${var.KEY_NAME}.pem",
      "chmod +x /tmp/task-0-environment-setup.sh",
      "sudo /tmp/task-0-environment-setup.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.KEY_NAME}.pem")
    host        = aws_instance.bastion-instance.public_ip
    agent       = false
    timeout     = "1m"
  }

}
