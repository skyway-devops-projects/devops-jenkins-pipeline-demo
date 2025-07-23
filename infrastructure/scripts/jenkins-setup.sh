#!/bin/bash
sudo apt update
sudo apt install openjdk-17-jdk nginx curl gnupg2 -y
sudo apt install maven -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

###
sudo tee /etc/nginx/sites-available/jenkins > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name jenkins.skywaytechsolutions.com;

    location / {
        proxy_pass         http://localhost:8080;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF
# Enable Jenkins site and restart NGINX
sudo ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# Wait for Jenkins to be up and responding on port 8080
echo "Waiting for Jenkins to start..."
for i in {1..60}; do
  if curl -s http://localhost:8080/login | grep "Jenkins" >/dev/null; then
    echo "Jenkins is up!"
    break
  fi
  echo "Jenkins not ready yet. Waiting..."
  sleep 10
done

sudo tee /home/ubuntu/plugins.txt > /dev/null <<EOF
git
workflow-aggregator
blueocean
job-dsl
dependency-check-jenkins-plugin
sonar:2.18
nodejs:1.6.4
docker-plugin:1.10.0
docker-workflow:621.va_73f881d9232
EOF

sudo wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar
sudo java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt --plugins delivery-pipeline-plugin:1.3.2 deployit-plugin
sudo systemctl restart jenkins

