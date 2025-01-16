#!/bin/bash

# 1. Instalare Docker
echo "Instalare Docker..."
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker

# 2. Instalare Docker Compose
echo "Instalare Docker Compose..."
sudo apt install -y docker-compose

# 3. Creare fișier docker-compose.yml
echo "Creare fișier Docker Compose pentru Prometheus..."
cat <<EOL > docker-compose.yml
version: '3'

services:
  prometheus:
    image: prom/prometheus:v2.40.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: always

EOL

# 4. Creare fișier Prometheus configuration
echo "Creare fișier Prometheus configuration..."
cat <<EOL > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'jupyterhub'
    static_configs:
      - targets: ['194.233.167.147:8000']  # IP-ul VM-ului și portul 8000 pentru JupyterHub
EOL

# 5. Health check pentru JupyterHub (verifică starea sănătății)
echo "Adăugare health check pentru JupyterHub..."
cat <<EOL > jupyterhub_healthcheck.sh
#!/bin/bash
# Verifică dacă JupyterHub răspunde la /hub/health
curl -f http://194.233.167.147:8000/hub/health
if [ \$? -eq 0 ]; then
  echo "JupyterHub este sănătos!"
else
  echo "JupyterHub nu este disponibil!"
fi
EOL
chmod +x jupyterhub_healthcheck.sh

# 6. Pornire containere Prometheus cu Docker Compose
echo "Pornire container Prometheus..."
sudo docker-compose up -d

# 7. Pornire health check periodic pentru JupyterHub
echo "Pornire health check pentru JupyterHub..."
while true; do
  ./jupyterhub_healthcheck.sh
  sleep 60  # Verifică la fiecare 60 de secunde
done &

# Afișează statusul containerelor pentru verificare
echo "Verificare stare containere..."
sudo docker-compose ps

echo "Instalare și configurare completă pentru Prometheus!"
