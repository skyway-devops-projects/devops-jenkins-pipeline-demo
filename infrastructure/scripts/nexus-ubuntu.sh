#!/bin/bash

# Update system
apt update -y && apt upgrade -y

# Install Java (Nexus requires Java 8 or 11)
apt install openjdk-11-jdk -y

# Create nexus user
useradd -M -d /opt/nexus -s /bin/false nexus

# Create required directories
mkdir -p /opt/nexus /opt/sonatype-work

# Download Nexus (change version as needed)
cd /opt
NEXUS_VERSION=3.68.0-01
wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

# Extract and rename
tar -xvzf nexus-${NEXUS_VERSION}-unix.tar.gz
mv nexus-${NEXUS_VERSION} nexus
rm nexus-${NEXUS_VERSION}-unix.tar.gz

# Set permissions
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Configure Nexus to run as nexus user
echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

# Create systemd service
cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Nexus
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

###
sudo tee /etc/nginx/sites-available/nuxus > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name nexus.skywaytechsolutions.com;

    location / {
        proxy_pass         http://localhost:8081;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
EOF
# Enable Jenkins site and restart NGINX
sudo ln -sf /etc/nginx/sites-available/nexus /etc/nginx/sites-enabled/nexus
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx


# Firewall (optional, if ufw is used)
# ufw allow 8081

# Echo default admin password
echo "Waiting for Nexus to initialize..."
sleep 60
cat /opt/sonatype-work/nexus3/admin.password > /root/nexus-admin-password.txt
