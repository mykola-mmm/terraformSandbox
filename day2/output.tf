output "website_url" {
  description = "Url of the website hosted in the bucket"
  value       = aws_s3_bucket_website_configuration.host_bucket_website_configuration.website_endpoint
}

output "latest_commit_sha" {
  description = "value of the latest commit sha"
  value       = data.local_file.latest_commit_sha.content
}

output "cloudfront_distribution_url" {
  description = "Url of the cloudfront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name	
}