provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type

  associate_public_ip_address = true
  vpc_security_group_ids      = [data.aws_security_group.default.id]

  root_block_device {
    volume_size = var.disk_size
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y

              # Instalar Docker
              yum install -y docker

              # Arrancar Docker
              systemctl start docker
              systemctl enable docker

              # Esperar a que Docker esté listo
              sleep 10

              # Crear carpeta para la web
              mkdir -p /home/ec2-user/html

              # Crear página HTML
              cat <<EOT > /home/ec2-user/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                <title>CloudGuard</title>
              </head>
              <body style="font-family: Arial; text-align:center; background:#f4f4f4; padding:50px;">
                <div style="background:white; padding:30px; border-radius:10px; display:inline-block; box-shadow:0 4px 10px rgba(0,0,0,0.1);">
                  <h1 style="color:#007bff;">CloudGuard Deployment</h1>
                  <p>Servidor: <strong>${var.name}</strong></p>
                  <p>Estado: <span style="color:green;">Activo</span></p>
                  <hr>
                  <p>Infraestructura desplegada automaticamente con:</p>
                  <p>Python + Terraform + Docker</p>
                </div>
              </body>
              </html>
              EOT

              # Ejecutar Nginx con la web
              docker run -d -p 80:80 \
                -v /home/ec2-user/html:/usr/share/nginx/html:ro \
                nginx
              EOF

  tags = {
    Name = var.name
  }
}

output "ip_publica" {
  value = aws_instance.web.public_ip
}