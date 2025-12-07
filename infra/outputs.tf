output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "input_bucket_name" {
  value = aws_s3_bucket.input_bucket.id
}