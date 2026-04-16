provider "aws" {
  region = var.region
}

# -------------------------
# VPC por defecto (AWS Academy)
# -------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# -------------------------
# SECURITY GROUP
# -------------------------
resource "aws_security_group" "web_sg" {
  name   = "sg_${var.name}"
  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# INSTANCIA EC2
# -------------------------
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = var.disk_size
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker

              mkdir -p /home/ec2-user/html

              cat <<EOT > /home/ec2-user/html/index.html
              <!DOCTYPE html>
              <html>
              <body style="font-family: sans-serif; text-align: center; background: #f4f4f4; padding: 50px;">
                <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); display: inline-block;">
                  <h1 style="color: #007bff;">🚀 CloudGuard Deployment</h1>
                  <p>El servidor <strong>${var.name}</strong> ha sido desplegado correctamente.</p>
                  <p>Estado: <span style="color: green;">✔ Activo</span></p>
                  <hr>
                  <p style="font-size: 0.8em; color: #666;">Automatizado con Python + Terraform + Docker</p>
                </div>
              </body>
              </html>
              EOT

              docker run -d -p 80:80 \
                -v /home/ec2-user/html:/usr/share/nginx/html:ro \
                nginx
              EOF

  tags = {
    Name = var.name
  }
}

# -------------------------
# OUTPUT
# -------------------------
output "ip_publica" {
  value = aws_instance.web.public_ip
}