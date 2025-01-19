#!/bin/bash

# Add the Prometheus GPG key
echo "Adăugare cheia GPG pentru Prometheus..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC
sudo apt update

export to_msid="+1234567890"
export from_msid="+1098765432"

# Create new files
touch prometeus.yml docker-compose.yml jupyterhub_healthcheck.sh alert.rules alertmanager.yml

# Update package list and install pip if not installed
echo "Verificare dacă pip este instalat..."
if ! command -v pip3 &> /dev/null
then
    echo "pip nu este instalat. Instalare pip..."
    sudo apt update
    sudo apt install -y python3-pip
else
    echo "pip este deja instalat."
fi

# 1. Install Docker
echo "Instalare Docker..."
sudo apt install -y docker.io
sudo systemctl enable --now docker

# 2. Install Docker Compose
echo "Instalare Docker Compose..."
sudo apt install -y docker-compose

# 3. Create docker-compose.yml file
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
      - ./prometeus.yml:/etc/prometheus/prometheus.yml
    restart: always
  alertmanager:
    image: prom/alertmanager:v0.24.0
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    restart: always
EOL

# 4. Create Prometheus configuration file and overwrite it if it exists
echo "Creare fișier Prometheus configuration..."
cat <<EOL > prometeus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'jupyterhub'
    static_configs:
      - targets: ['192.168.50.201:8000']  # Adjust with the correct IP and port for JupyterHub

  - job_name: 'jupyterhub-metrics'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['localhost:8000']

  - job_name: 'jupyterhub-health'
    metrics_path: '/hub/health'
    static_configs:
      - targets: ['192.168.50.201:8000']
EOL

# 5. Add health check script for JupyterHub
echo "Adăugare health check pentru JupyterHub..."
cat <<EOL > jupyterhub_healthcheck.sh
#!/bin/bash
# Verifică dacă JupyterHub răspunde la /hub/health
curl -f http://192.168.50.201:8000/hub/health
if [ \$? -eq 0 ]; then
  echo "JupyterHub este sănătos!"
else
  echo "JupyterHub nu este disponibil!"
fi
EOL
chmod +x jupyterhub_healthcheck.sh

# 6. Create alert rules for Prometheus
echo "Creare fișier alert.rules pentru Prometheus..."
cat <<EOL > alert.rules
groups:
- name: jupyterhub-alerts
  rules:
  - alert: JupyterHubDown
    expr: up{job="jupyterhub-health"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "JupyterHub is down for more than 5 minutes"
      description: "JupyterHub has been unresponsive for more than 5 minutes."
  - alert: JupyterHubNoMetrics
    expr: up{job="jupyterhub-metrics"} == 0
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "No metrics from JupyterHub"
      description: "JupyterHub is not providing metrics for the last 5 minutes."
EOL

# 7. Create Alertmanager configuration file
echo "Creare fișier alertmanager.yml pentru Alertmanager..."
cat <<EOL > alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'sms_notifications'

receivers:
  - name: 'sms_notifications'
    sms_configs:
      - to: "\${to_msid}"  # Replace with the actual phone number
        from: "\${from_msid}"  # Replace with the actual sender number
        message: "Alert: JupyterHub is down!"
EOL

export to_msid
export from_msid

# 8. Start Prometheus and Alertmanager containers with Docker Compose
echo "Pornire containere Prometheus și Alertmanager..."
sudo docker-compose up -d

# 9. Start periodic health check for JupyterHub
echo "Pornire health check pentru JupyterHub..."
while true; do
  ./jupyterhub_healthcheck.sh
  sleep 60  # Verifică la fiecare 60 de secunde
done &

# Show container status for verification
echo "Verificare stare containere..."
sudo docker-compose ps

echo "Instalare și configurare completă pentru Prometheus!"
