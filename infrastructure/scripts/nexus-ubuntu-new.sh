#!/bin/bash

sudo apt update -y

sudo apt install openjdk-17-jdk nginx curl gnupg2  -y

sudo useradd -d /opt/nexus -s /bin/bash nexus

cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.82.0-08-linux-x86_64.tar.gz
sudo tar xzf nexus-3.82.0-08-linux-x86_64.tar.gz
sudo mv nexus-3.82.0-08  /opt/nexus
sudo mv sonatype-work /opt/sonatype-work
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc > /dev/null
###

sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
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
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

###
sudo tee /etc/nginx/sites-available/jenkins > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name nuxus.skywaytechsolutions.com;

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
sudo ln -sf /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx


#cat /opt/sonatype-work/nexus3/admin.password
