
output "login" {
  value = <<-EOT

    URL:               https://s3.amazonaws.com/${local.name}/index.html
    Access Key ID:     ${aws_iam_access_key.app_user.id}
    Secret Access Key: ${nonsensitive(aws_iam_access_key.app_user.secret)}
  EOT
}
