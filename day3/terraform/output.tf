output "website_url" {
  description = "Url of the website hosted in the bucket"
  value       = aws_s3_bucket_website_configuration.host_bucket_website_configuration.website_endpoint
}