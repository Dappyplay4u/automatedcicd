# IAM Role and Policy
resource "aws_iam_role" "jenkin_cicd_server" {
  name = "jenkin-cicd-server-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "administrator_access" {
  name        = "AdministratorAccess"
  description = "Policy granting full administrative access"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins_cicd_server_attachment" {
  policy_arn = aws_iam_policy.administrator_access.arn
  role       = aws_iam_role.jenkin_cicd_server.name
}
