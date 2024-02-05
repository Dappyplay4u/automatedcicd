output "iamrole_server_id" {
  value = aws_iam_role.jenkin_cicd_server.id

}

output "iampolicy_id" {
  value = aws_iam_policy.administrator_access.id

}

