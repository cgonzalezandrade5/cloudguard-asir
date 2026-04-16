provider "aws" {
  region = var.region
}

# AMI fija (evita problemas de permisos en AWS Academy)
variable "ami_id" {
  default = "ami-0c02fb55956c7d316"
}

# -----------------------
# INSTANCIA EC2
# -----------------------
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Security Group por defecto del entorno (OBLIGATORIO en AWS Academy)
  vpc_security_group_ids = [data.aws_security_group.default.id]

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
              <head>
                <title>CloudGuard</title>
              </head>
              <body style="font-family: Arial; text-align:center; background:#f4f4f4; padding:50px;">

                <div style="background:white; padding:30px; border-radius:10px; display:inline-block; box-shadow:0 4px 10px rgba(0,0,0,0.1);">

                  <h1 style="color:#007bff;">🚀 CloudGuard Deployment</h1>

                  <p>Servidor: <strong>${var.name}</strong></p>
                  <p>Estado: <span style="color:green;">✔ Activo</span></p>

                  <hr>

                  <p>Infraestructura desplegada automáticamente con:</p>
                  <p>Python + Terraform + Docker</p>

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

# -----------------------
# SECURITY GROUP DEFAULT (AWS ACADEMY)
# -----------------------
data "aws_security_group" "default" {
  name = "default"
}

# -----------------------
# OUTPUT
# -----------------------
output "ip_publica" {
  value = aws_instance.web.public_ip
}