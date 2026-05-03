# CloudGuard ASIR

**Automatización de infraestructura cloud: Terraform + Python + Docker**

Despliega servidores en AWS de forma automatizada. Valida configuraciones antes de crearlos, sin errores manuales.

---

## ⚡ Quick Start

### 1. Instalación (5 min)

```bash
# Clonar
git clone https://github.com/tu-usuario/cloudguard-asir.git
cd cloudguard-asir

# Instalar herramientas (Ubuntu/Linux)
sudo snap install terraform --classic
sudo apt install awscli docker.io
python3 -m pip install pyyaml

# Configurar AWS
aws configure
# (pega tu Access Key, Secret Key, región: us-east-1, formato: json)
```

### 2. Configurar tu servidor

Edita `config/config.yaml`:

```yaml
server:
  name: "mi-servidor"
```

Listo. El resto de parámetros se rellenan automáticamente.

### 3. Desplegar

```bash
# Validar config
python3 main.py

# Ir a terraform
cd terraform
terraform init
terraform plan
terraform apply  # escribe 'yes'
```

¡Tu servidor está online! Usa la IP que te muestre Terraform.

---

## 📁 Archivos principales

| Archivo | Qué hace |
|---------|----------|
| `config/config.yaml` | Tu configuración (edita esto) |
| `config/defaults.yaml` | Valores por defecto |
| `main.py` | Valida y genera configuración |
| `terraform/main.tf` | Define la infraestructura |
| `templates/index.html` | Página web del servidor |

---

## 🔧 Cómo funciona

```
config.yaml → Python valida → terraform.tfvars.json → Terraform → AWS
```

1. **config.yaml**: Defines el nombre del servidor
2. **main.py**: Valida parámetros, completa con defaults
3. **Terraform**: Crea la instancia EC2
4. **Docker**: Ejecuta Nginx con página web
5. **IP pública**: Accede al servidor

---

## 📝 Configuración disponible

```yaml
server:
  name: "servidor"             # Nombre (personalizable)
  region: "us-east-1"          # Región (solo ésta en Academy)
  instance_type: "t2.micro"    # Tipo (gratuito en Academy)
  disk_size: 10                # GB (8-30)
  open_ports: [22, 80]         # Puertos abiertos (SSH y HTTP)
```

> **Nota**: Usa AWS Academy con VPC y Security Group por defecto (restricciones de la plataforma).

---

## 🛑 Eliminar infraestructura

```bash
cd terraform
terraform destroy  # escribe 'yes'
```

---

## 🤝 Contribuir

1. Fork el proyecto
2. Crea rama: `git checkout -b feature/MiMejora`
3. Commit: `git commit -m "Añado: descripción"`
4. Push: `git push origin feature/MiMejora`
5. Pull Request

---

## 👤 Autor

**Cristina Isabel González Andrade**  
ASIR 2025/2026 - IES Bezmiliana

---

## 📄 Licencia

MIT
