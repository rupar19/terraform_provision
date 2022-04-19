resource "aws_key_pair" "terra-key" {
  key_name   = "terra"
  public_key = file("terra.pub")
}

resource "aws_instance" "terra-instance" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1
  key_name               = aws_key_pair.terra-key.key_name
  vpc_security_group_ids = ["sg-0f1d4207f7a9a08da"]

  tags = {
    Name    = "terraInstance"
    Project = "terraform project"
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = var.USER
    private_key = file("terra")
    host        = self.public_ip

  }
}

output "instance_public_ip" {
  value = aws_instance.terra-instance.public_ip
}

output "instance_private_ip" {
  value = aws_instance.terra-instance.private_ip
}
