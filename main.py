import yaml         # Para leer/escribir archivos YAML
import json         # Para leer/escribir archivos JSON 
import os           # Para manejar rutas de archivos y verificar su existencia

# Rutas de archivos (Organizadas por carpetas)
CONFIG_FILE = "config/config.yaml"
DEFAULTS_FILE = "config/defaults.yaml"
FINAL_YAML = "config/final_config.yaml"
TERRAFORM_VARS = "terraform/terraform.tfvars.json"

def load_yaml(file_path):
    """Carga un archivo YAML de forma segura"""
    if not os.path.exists(file_path):
        print(f"❌ Error: No se encuentra el archivo {file_path}")
        return {"server": {}}
    with open(file_path, 'r') as file:
        return yaml.safe_load(file) or {"server": {}}

def merge_config(user_config, default_config):
    """
    Combina la configuración del usuario con los valores por defecto.
    La configuración del usuario siempre tiene prioridad.
    """
    final_config = {}
    
    # Obtenemos los bloques 'server', si no existen usamos diccionarios vacíos
    user_server = user_config.get("server", {})
    default_server = default_config.get("server", {})

    # Iteramos sobre todas las claves presentes en los valores por defecto
    for key in default_server:
        # Si el usuario ha definido la clave y no es nula, la usamos
        if key in user_server and user_server[key] is not None:
            final_config[key] = user_server[key]
        else:
            # Si no, aplicamos el valor por defecto
            final_config[key] = default_server[key]

    return {"server": final_config}

def validate_academy_restrictions(config):
    """
    Aplica las restricciones específicas de AWS Academy para evitar errores de despliegue.
    """
    # 1. Validar Región (Solo us-east-1 permitida)
    if config["server"]["region"] != "us-east-1":
        print(f"⚠️  Región '{config['server']['region']}' no permitida. Ajustando a 'us-east-1'.")
        config["server"]["region"] = "us-east-1"
    
    # 2. Validar Tipo de Instancia (t2.micro es la estándar de capa gratuita)
    if config["server"]["instance_type"] != "t2.micro":
        print(f"⚠️  Instancia '{config['server']['instance_type']}' podría tener costes. Ajustando a 't2.micro'.")
        config["server"]["instance_type"] = "t2.micro"

    # 3. Validar puertos (deben ser números entre 1 y 65535)
    ports = config["server"].get("open_ports", [])
    if not isinstance(ports, list):
        print(f"⚠️  open_ports debe ser una lista. Ajustando a [22, 80].")
        config["server"]["open_ports"] = [22, 80]
    else:
        valid_ports = []
        for port in ports:
            if isinstance(port, int) and 1 <= port <= 65535:
                valid_ports.append(port)
            else:
                print(f"⚠️  Puerto '{port}' no válido (debe ser entero entre 1 y 65535). Ignorado.")
        if not valid_ports:
            print("⚠️  No hay puertos válidos. Ajustando a [22, 80].")
            valid_ports = [22, 80]
        config["server"]["open_ports"] = valid_ports

    # 4. Validar tamaño de disco (entre 8 y 30 GB para Academy)
    disk = config["server"].get("disk_size", 8)
    if not isinstance(disk, (int, float)) or disk < 8 or disk > 30:
        print(f"⚠️  Disco '{disk}' GB fuera de rango (8-30). Ajustando a 8 GB.")
        config["server"]["disk_size"] = 8
        
    return config

def main():
    print("--- 🛡️  CloudGuard: Iniciando Proceso de Validación ---")

    # 1. Cargar configuraciones
    user_config = load_yaml(CONFIG_FILE)
    default_config = load_yaml(DEFAULTS_FILE)

    # 2. Mezclar configuraciones
    final_config = merge_config(user_config, default_config)

    # 3. Validar restricciones de AWS Academy
    final_config = validate_academy_restrictions(final_config)

    print("✅ Validación completada con éxito.")

    # 4. Guardar resultado en YAML (Para lectura humana)
    os.makedirs("config", exist_ok=True) # Crea la carpeta si no existe
    with open(FINAL_YAML, "w") as file:
        yaml.dump(final_config, file, default_flow_style=False)
    print(f"💾 Resumen guardado en: {FINAL_YAML}")

    # 5. Generar JSON para Terraform (Para lectura de la máquina)
    # Terraform lee mejor los archivos .json para las variables
    # Solo exportamos las variables que Terraform declara en variables.tf
    terraform_keys = ["name", "region", "instance_type", "disk_size", "open_ports"]
    terraform_vars = {k: v for k, v in final_config["server"].items() if k in terraform_keys}
    os.makedirs("terraform", exist_ok=True)
    with open(TERRAFORM_VARS, "w") as f:
        json.dump(terraform_vars, f, indent=4)
    print(f"🚀 Archivo de variables generado: {TERRAFORM_VARS}")

if __name__ == "__main__":
    main()