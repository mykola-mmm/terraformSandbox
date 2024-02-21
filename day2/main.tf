terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "server" {
  prefix    = var.bucket_prefix
  length    = 4
  separator = "-"
}

resource "aws_s3_bucket" "host_bucket" {
  bucket = random_pet.server.id
}

resource "aws_s3_bucket_acl" "host_bucket_acl" {
  bucket = aws_s3_bucket.host_bucket.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.host_bucket_acl_ownership,
    aws_s3_bucket_public_access_block.host_bucket_public_access_block
  ]
}

resource "aws_s3_bucket_ownership_controls" "host_bucket_acl_ownership" {
  bucket = aws_s3_bucket.host_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "host_bucket_public_access_block" {
  bucket = aws_s3_bucket.host_bucket.id
}

data "aws_iam_policy_document" "host_bucket_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.host_bucket.arn,
      "${aws_s3_bucket.host_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "host_bucket_policy" {
  bucket = aws_s3_bucket.host_bucket.id
  policy = data.aws_iam_policy_document.host_bucket_allow_public_access.json
  depends_on = [ aws_s3_bucket_acl.host_bucket_acl ]
}

resource "aws_s3_bucket_website_configuration" "host_bucket_website_configuration" {
    bucket = aws_s3_bucket.host_bucket.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}