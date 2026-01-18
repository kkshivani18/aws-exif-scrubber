# AWS Exif Scrubber

## Overview
AWS Exif Scrubber is a serverless solution to automatically remove EXIF metadata from images uploaded to an S3 bucket. It uses AWS Lambda (containerized with Docker), S3 and Terraform for infrastructure management.

## Features
- Automatically scrubs EXIF data from images (.jpg) uploaded to S3.
- Stores cleaned images in a separate output bucket.
- Infrastructure as Code using Terraform.
- Containerized Lambda function using Docker.

## Architecture

![Project Architecture](<./images/architecture.png>)  

- **Input S3 Bucket**: Receives original images.
- **Lambda Function**: Triggered by S3 events, processes images, removes EXIF, and saves to output bucket.
- **Output S3 Bucket**: Stores cleaned images.
- **ECR**: Hosts Lambda container image.

## Setup Instructions

### Prerequisites
- AWS CLI configured
- Terraform installed
- Docker installed

### 1. Infrastructure Deployment
```sh
cd infra
terraform init
terraform apply
```

### 2. Build & Push Lambda Image
```sh
docker build -t aws-exif-scrubber .
# Authenticate Docker to ECR and push the image
```

### 3. Upload Images
- Upload `.jpg` images to the input S3 bucket (`<project_name>-input`).
- Cleaned images will appear in the output bucket (`<project_name>-output`).

## Usage
- All EXIF metadata is removed from images.
- Logs are available in AWS CloudWatch.

## Infrastructure (Terraform)
- S3 buckets for input/output
- ECR repository for Lambda image
- IAM roles and permissions
- Lambda function and S3 event trigger

## Docker
- Uses AWS Lambda Python 3.12 base image.
- Installs dependencies from `requirements.txt`.
- Entrypoint is `exif-cleaner.handler`.

## Lambda
- Python handler in `exif-cleaner.py`.
- Uses Pillow for image processing.

## S3 Buckets
- Input: `aws-exif-scrubber-input`
- Output: `aws-exif-scrubber-output`

### Article on Medium

[Checkout the article on Medium](https://medium.com/@kkrishnashivani18/lambda-to-silence-your-snitch-camera-0e482f8451da)
