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

provider "aws" {
  region = "us-west-2"
}

# Data source to reference the existing S3 bucket:
data "aws_s3_bucket" "existing_bucket" {
  bucket = "dev-artifacts-repo"
}

# Create the SNS Topic without a policy
resource "aws_sns_topic" "s3_notification_topic" {
  name = "packer-aws-ami-with-git-actions"
}

# Create the SNS Topic Policy separately
resource "aws_sns_topic_policy" "s3_notification_topic_policy" {
  arn = aws_sns_topic.s3_notification_topic.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "${aws_sns_topic.s3_notification_topic.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${data.aws_s3_bucket.existing_bucket.arn}"
        }
      }
    }
  ]
}
POLICY
}

# Subscribe an Email to the SNS Topic:
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.s3_notification_topic.arn
  protocol  = "email"
  endpoint  = "amos.egonmwan@hotmail.com"
}

# Configure S3 Bucket Notification:
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.existing_bucket.id

  topic {
    topic_arn = aws_sns_topic.s3_notification_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
