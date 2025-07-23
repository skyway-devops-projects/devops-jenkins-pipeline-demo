#!/bin/bash
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar
sudo java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt --plugins delivery-pipeline-plugin:1.3.2 deployit-plugin
sudo systemctl restart jenkins
# sudo java -jar jenkins-plugin-manager-2.13.2.jar \
#   --war /usr/share/java/jenkins.war \
#   --plugin-file plugins.txt \
#   --plugin-download-directory /var/lib/jenkins/plugins -d plugins/plugins\
#   --verbose
#eaeae46e-cd3c-479b-9c21-6bd85497f290




# #java -jar jenkins-cli.jar -s $JENKINS_URL install-plugin SOURCE ... [-deploy] [-name VAL] [-restart]


# java -jar jenkins-cli.jar -s $JENKINS_URL -auth admin:admin install-plugin  docker-workflow:621.va_73f881d9232 -deploy
# java -jar jenkins-cli.jar -s $JENKINS_URL -auth admin:admin install-plugin build-timeout:1.38 -deploy
# java -jar jenkins-cli.jar -s $JENKINS_URL -auth admin:admin   install-plugin blueocean:1.27.20 -deploy


# java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war --plugin-download-directory /your/path/to/plugins/ --plugin-file /your/path/to/plugins.txt --plugins delivery-pipeline-plugin:1.3.2 deployit-plugin


