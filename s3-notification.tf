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
    key    = "github-actions/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

# Define the SNS Topic:
resource "aws_sns_topic" "s3_notification_topic" {
  name = "packer-aws-ami-with-git-actions"
}

# Subscribe an Email to the SNS Topic:
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.s3_notification_topic.arn
  protocol  = "email"
  endpoint  = "amos.egonmwan@hotmail.com"
}

# Configure S3 Bucket Notification:
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "s3-remote-backend-2024"

  topic {
    topic_arn = aws_sns_topic.s3_notification_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
