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
  bucket     = aws_s3_bucket.host_bucket.id
  policy     = data.aws_iam_policy_document.host_bucket_allow_public_access.json
  depends_on = [aws_s3_bucket_acl.host_bucket_acl]
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

resource "null_resource" "latest_commit_sha" {
  triggers = { always_run = "${timestamp()}" }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "curl -s ${var.github_master_branch_url} | jq -r .sha > latest_commit_sha.txt"
  }
}

data "local_file" "latest_commit_sha" {
  depends_on = [null_resource.latest_commit_sha]
  filename   = "latest_commit_sha.txt"
}

resource "null_resource" "download_repo" {
  triggers = {
    commit_sha = filemd5(data.local_file.latest_commit_sha.filename)
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "git clone ${var.github_repo_url} ./src"
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "cp -rf ./src/Website ./website"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "rm -rf ./src"
  }
}

module "template_files" {
  depends_on = [null_resource.download_repo]
  source     = "hashicorp/dir/template"

  base_dir = "${path.module}/website"
}


resource "aws_s3_object" "host_bucket_files" {
  depends_on = [module.template_files]

  bucket   = aws_s3_bucket.host_bucket.id
  for_each = module.template_files.files

  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  etag = each.value.digests.md5
}

# resource "aws_cloudfront_distribution" "cloudfront_distribution" {
#   aliases                        = []
#   arn                            = "arn:aws:cloudfront::321206642389:distribution/E1G7N254BFG1J0"
#   caller_reference               = "4fab7061-b809-40bb-bb89-15a4a25a2bd6"
#   domain_name                    = "d2mi7wtj9y8c22.cloudfront.net"
#   enabled                        = true
#   etag                           = "E189VKW7BWZXWD"
#   hosted_zone_id                 = "Z2FDTNDATAQYW2"
#   http_version                   = "http2"
#   id                             = "E1G7N254BFG1J0"
#   in_progress_validation_batches = 0
#   is_ipv6_enabled                = true
#   last_modified_time             = "2024-02-27 20:19:01.8 +0000 UTC"
#   price_class                    = "PriceClass_All"
#   retain_on_delete               = false
#   status                         = "Deployed"
#   tags                           = {}
#   tags_all                       = {}
#   trusted_key_groups = [
#     {
#       enabled = false
#       items   = []
#     },
#   ]
#   trusted_signers = [
#     {
#       enabled = false
#       items   = []
#     },
#   ]
#   wait_for_deployment = true

#   default_cache_behavior {
#     allowed_methods = [
#       "GET",
#       "HEAD",
#     ]
#     cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
#     cached_methods = [
#       "GET",
#       "HEAD",
#     ]
#     compress               = true
#     default_ttl            = 0
#     max_ttl                = 0
#     min_ttl                = 0
#     smooth_streaming       = false
#     target_origin_id       = "mykola-mmm-s3-bucket-frankly-wrongly-enormous-buzzard.s3-website.eu-central-1.amazonaws.com"
#     trusted_key_groups     = []
#     trusted_signers        = []
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   origin {
#     connection_attempts = 3
#     connection_timeout  = 10
#     domain_name         = "mykola-mmm-s3-bucket-frankly-wrongly-enormous-buzzard.s3-website.eu-central-1.amazonaws.com"
#     origin_id           = "mykola-mmm-s3-bucket-frankly-wrongly-enormous-buzzard.s3-website.eu-central-1.amazonaws.com"

#     custom_origin_config {
#       http_port                = 80
#       https_port               = 443
#       origin_keepalive_timeout = 5
#       origin_protocol_policy   = "http-only"
#       origin_read_timeout      = 30
#       origin_ssl_protocols = [
#         "SSLv3",
#         "TLSv1",
#         "TLSv1.1",
#         "TLSv1.2",
#       ]
#     }
#   }

#   restrictions {
#     geo_restriction {
#       locations        = []
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#     minimum_protocol_version       = "TLSv1"
#   }
# }

resource "aws_cloudfront_origin_access_control" "s3_origin_access_control" {
  name                              = "example"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.host_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin_access_control.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["US","GB","DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}