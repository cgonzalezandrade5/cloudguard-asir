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

              # Escribir el HTML generado desde la plantilla
              cat <<'EOT' > /home/ec2-user/html/index.html
              ${templatefile("${path.module}/../templates/index.html", {
                name          = var.name
                instance_type = var.instance_type
                region        = var.region
                disk_size     = var.disk_size
                open_ports    = join(", ", var.open_ports)
              })}
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