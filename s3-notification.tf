terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "s3-remote-backend-2024"
    key    = "packer-ami-actions/terraform.tfstate"
    region = "us-west-2"
  }
}

# Define the AWS provider
provider "aws" {
  region = "us-west-2"
}
#########################################################
# Reference to the existing S3 bucket using a data source
data "aws_s3_bucket" "dev_artifacts_repo" {
  bucket = "dev-artifacts-repo"
}

# Create an SNS topic
resource "aws_sns_topic" "s3_bucket_notifications" {
  name = "s3-bucket-email-notifications"
}

# Create a policy for the SNS topic allowing S3 to publish to it
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.s3_bucket_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.s3_bucket_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${data.aws_s3_bucket.dev_artifacts_repo.bucket}"
          }
        }
      }
    ]
  })
}

# Subscribe your email address to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.s3_bucket_notifications.arn
  protocol  = "email"
  endpoint  = "amos.egonmwan@hotmail.com"
}

# Create S3 bucket notification to trigger SNS topic
resource "aws_s3_bucket_notification" "s3_event_notifications" {
  bucket = data.aws_s3_bucket.dev_artifacts_repo.id

  topic {
    topic_arn = aws_sns_topic.s3_bucket_notifications.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:ObjectRestore:Completed", "s3:Replication:*"]
  }
}