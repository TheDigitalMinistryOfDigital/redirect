data "aws_s3_bucket_object" "lambda_zip" {
  bucket = "${var.domain}-redirector-bucket"
  key = "lambda.zip"
}

resource "aws_lambda_function" "redirector" {
  s3_bucket     = "${data.aws_s3_bucket_object.lambda_zip.bucket}"
  s3_key        = "${data.aws_s3_bucket_object.lambda_zip.key}"
  s3_object_version = "${data.aws_s3_bucket_object.lambda_zip.version_id}"
  function_name = "${var.redirector_lambda_name}"
  handler       = "index.handler"
  timeout       = 10
  role          = "${aws_iam_role.role.arn}"
  runtime       = "nodejs6.10"
}

resource "aws_iam_role" "role" {
  name = "aws_iam_lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
