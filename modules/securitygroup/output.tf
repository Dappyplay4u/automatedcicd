output "jenkins_security_group_id" {
    value = aws_security_group.jenkins_security_group.id
}
output "SonaQube_security_group_id" {
    value = aws_security_group.SonaQube_security_group.id
}

# output "webserver_security_group_id" {
#     value = aws_security_group.webserver_security_group.id
# }

output "Nexus_security_group_id" {
    value = aws_security_group.Nexus_security_group.id
}

output "Prometheus_security_group_id" {
    value = aws_security_group.Prometheus_security_group.id
}

output "Grafana_security_group_id" {
    value = aws_security_group.Grafana_security_group.id
}


