resource "aws_s3_bucket" "vpc_logs_buckets" {
  bucket = "${var.prefix_name}-${var.environment}-vpc-logs-bucket"
}

resource "aws_flow_log" "main" {
  log_destination      = aws_s3_bucket.vpc_logs_buckets.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id

  tags = merge(
    { Name = "${var.prefix_name}-${var.environment}-vpc-logs" },
    var.tags
  )
}