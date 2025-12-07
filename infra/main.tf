# s3 bucket
resource "aws_s3_bucket" "input_bucket" {
  bucket        = "${var.project_name}-input"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket        = "${var.project_name}-output"
  force_destroy = true
}

# block public access
resource "aws_s3_bucket_public_access_block" "input_block" {
  bucket = aws_s3_bucket.input_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ecr repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repo"
  force_delete = true
}

# IAM role
resource "aws_iam_role" "lambda_role"{
  name = "${var.project_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# attach permissions
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# lambda func
resource "aws_lambda_function" "scrubber_function" {
  function_name = "${var.project_name}-lambda-func"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  
  # repo URL
  image_uri     = "${aws_ecr_repository.app_repo.repository_url}:latest"
  
  timeout       = 60
  memory_size   = 512

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_ecr_repository.app_repo
  ]
}

# trigger (s3 notif)
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scrubber_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.scrubber_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}