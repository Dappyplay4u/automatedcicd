#####server-id

# output "web-server-prod-id" {
#   value = aws_instance.web-server-prod.id

# }

# output "web-server-stage-id" {
#   value = aws_instance.web-server-stage.id

# }

# output "web-server-dev-id" {
#   value = aws_instance.web-server-dev.id

# }

output "jenkins_server-id" {
  value = aws_instance.jenkins_server.id

}

output "Prometheus_server-id" {
  value = aws_instance.Prometheus_server.id

}

output "Grafana_server-id" {
  value = aws_instance.Grafana_server.id

}

output "SonaQube_server-id" {
  value = aws_instance.SonaQube_server.id

}

output "Nexus_server-id" {
  value = aws_instance.Nexus_server.id

}



#####server public ip

# output "web-server-prod-public_ip" {
#   value = aws_instance.web-server-prod.public_ip
# }

# output "web-server-stage-public_ip" {
#   value = aws_instance.web-server-stage.public_ip
# }

# output "web-server-dev-public_ip" {
#   value = aws_instance.web-server-dev.public_ip
# }

output "jenkins_server-public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "Prometheus_server-public_ip" {
  value = aws_instance.Prometheus_server.public_ip
}

output "Grafana_server-public_ip" {
  value = aws_instance.Grafana_server.public_ip
}

output "SonaQube_server-public_ip" {
  value = aws_instance.SonaQube_server.public_ip
}

output "Nexus_server-public_ip" {
  value = aws_instance.Nexus_server.public_ip
}


#####server private ip

# output "web-server-prod-private_ip" {
#   value = aws_instance.web-server-prod.private_ip
# }

# output "web-server-stage-private_ip" {
#   value = aws_instance.web-server-stage.private_ip
# }

# output "web-server-dev-private_ip" {
#   value = aws_instance.web-server-dev.private_ip
# }

output "jenkins_server-private_ip" {
  value = aws_instance.jenkins_server.private_ip
}

output "Prometheus_server-private_ip" {
  value = aws_instance.Prometheus_server.private_ip
}

output "Grafana_server-private_ip" {
  value = aws_instance.Grafana_server.private_ip
}

output "SonaQube_server-private_ip" {
  value = aws_instance.SonaQube_server.private_ip
}

output "Nexus_server-private_ip" {
  value = aws_instance.Nexus_server.private_ip
}


# print the url of the server

# output "web-server-prod_ipv4_url" {
#   value = join("", ["http://", aws_instance.web-server-prod.public_ip])
# }

# output "web-server-stage_ipv4_url" {
#   value = join("", ["http://", aws_instance.web-server-stage.public_ip])
# }

# output "web-server-dev_ipv4_url" {
#   value = join("", ["http://", aws_instance.web-server-dev.public_ip])
# }

output "jenkins_server_ipv4_url" {
  value = join("", ["http://", aws_instance.jenkins_server.public_ip])
}

output "Prometheus_server_ipv4_url" {
  value = join("", ["http://", aws_instance.Prometheus_server.public_ip])
}

output "SonaQube_server_ipv4_url" {
  value = join("", ["http://", aws_instance.SonaQube_server.public_ip])
}

output "Grafana_server_ipv4_url" {
  value = join("", ["http://", aws_instance.Grafana_server.public_ip])
}

output "Nexus_server_ipv4_url" {
  value = join("", ["http://", aws_instance.Nexus_server.public_ip])
}

