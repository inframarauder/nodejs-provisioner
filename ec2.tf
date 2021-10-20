# get latest ubuntu ami using data source:

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

output "test" {
  value = data.aws_ami.ubuntu.image_id
}

#ec2 instance with remote provisioner to install nodejs

resource "aws_instance" "nodejs_server" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type
  tags = {
    Name = "nodejs_server"
  }

  # Configure remote-exec to install nodejs
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y curl",
      "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "node -v > node_version.txt"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./ec2-key.pem")
    }
  }
}