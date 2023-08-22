terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default" # name of the profile in credentials file
}

# Archive lambda function
data "archive_file" "addHouseLambda" {
  type        = "zip"
  source_dir  = "addHouse/dist"
  output_path = "${path.module}/.terraform/archive_files/addHouseLambda.zip"

  depends_on = [null_resource.addHouseLambda]
}

# Provisioner to install dependencies in lambda package before upload it.
resource "null_resource" "addHouseLambda" {

  triggers = {
    updated_at = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
    yarn
    yarn run compile
    EOF

    working_dir = "${path.module}/addHouse"
  }
}

resource "aws_lambda_function" "add_house_lambda" {
  filename      = "${path.module}/.terraform/archive_files/addHouseLambda.zip"
  function_name = "add_house_lambda"
  role          = aws_iam_role.add_house_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout = 300

  source_code_hash = data.archive_file.addHouseLambda.output_base64sha256
}

resource "aws_iam_role" "add_house_lambda_role" {
  name               = "lambda_hello_world_role"
  assume_role_policy = <<EOF
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
EOF
  inline_policy {
    name = "lamda-hello-world-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "LambdaHelloWorld1",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}