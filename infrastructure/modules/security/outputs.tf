output "jenkins_security_group_id" {
  description = "ID of the Jenkins security group"
  value       = aws_security_group.jenkins_sg.id
}

output "nexus_security_group_id" {
  description = "ID of the nuxus security group"
  value       = aws_security_group.nexus_sg.id
}

output "sonar_security_group_id" {
  description = "ID of the Sonar security group"
  value       = aws_security_group.sonar_sg.id
}

