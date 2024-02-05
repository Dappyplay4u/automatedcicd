# Outputs
output "jenkins_server_private_ip" {
  description = "Private IP address of the Jenkins server"
  value       = aws_instance.jenkins_server.private_ip
}

output "Nexus_server_private_ip" {
  description = "Private IP address of the Nexus server"
  value       = aws_instance.Nexus_server.private_ip
}

output "Prometheus_server_private_ip" {
  description = "Private IP address of the Prometheus server"
  value       = aws_instance.Prometheus_server.private_ip
}

output "Grafana_server_private_ip" {
  description = "Private IP address of the Grafana server"
  value       = aws_instance.Grafana_server.private_ip
}

output "SonaQube_server_private_ip" {
  description = "Private IP address of the SonaQube server"
  value       = aws_instance.SonaQube_server.private_ip
}
