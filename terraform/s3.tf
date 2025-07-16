resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.project_name}-static-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "${var.project_name}-static"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket                  = aws_s3_bucket.static_assets.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_assets" {
  bucket     = aws_s3_bucket.static_assets.id
  depends_on = [aws_s3_bucket_public_access_block.static_assets]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_assets.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_website_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "index.html"
  source       = "../web-app/index.html"
  content_type = "text/html"
  etag         = filemd5("../web-app/index.html")
}

resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "css/style.css"
  source       = "../web-app/css/style.css"
  content_type = "text/css"
  etag         = filemd5("../web-app/css/style.css")
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "js/app.js"
  source       = "../web-app/js/app.js"
  content_type = "application/javascript"
  etag         = filemd5("../web-app/js/app.js")
}

resource "aws_s3_object" "logo" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "images/logo.png"
  source       = "../web-app/images/logo.png"
  content_type = "image/png"
  etag         = filemd5("../web-app/images/logo.png")
}
