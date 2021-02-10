terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Let's create a role first
resource "aws_iam_role" "screenshooter" {
  name               = "screenshooter"
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
}

# Now let's create the function
resource "aws_lambda_function" "screenshooter" {
  function_name = "ScreenShooter"
  filename      = "bundle.zip"
  role          = aws_iam_role.screenshooter.arn # The role from above
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  # Get the layer from https://github.com/shelfio/chrome-aws-lambda-layer
  layers = ["arn:aws:lambda:eu-central-1:764866452798:layer:chrome-aws-lambda:20"]
  # Give the lambda plenty of memory
  memory_size = 1600
  timeout     = 30
}


# API Gateway
resource "aws_api_gateway_rest_api" "screenshooter_api" {
  name        = "screenshooter-api"
  description = "An API to our ScreenShooter Lambda"

  # We need this so we can return an image.
  binary_media_types = ["*/*"]
}

resource "aws_api_gateway_resource" "screenshooter_root" {
  rest_api_id = aws_api_gateway_rest_api.screenshooter_api.id
  parent_id   = aws_api_gateway_rest_api.screenshooter_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "screenshooter_method" {
  rest_api_id   = aws_api_gateway_rest_api.screenshooter_api.id
  resource_id   = aws_api_gateway_resource.screenshooter_root.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "screenshooter_lambda_connection" {
  rest_api_id = aws_api_gateway_rest_api.screenshooter_api.id
  resource_id = aws_api_gateway_resource.screenshooter_root.id
  http_method = aws_api_gateway_method.screenshooter_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.screenshooter.invoke_arn
}

resource "aws_api_gateway_method" "screenshooter_method_root" {
  rest_api_id   = aws_api_gateway_rest_api.screenshooter_api.id
  resource_id   = aws_api_gateway_rest_api.screenshooter_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "screenshooter_lambda_connection_root" {
  rest_api_id = aws_api_gateway_rest_api.screenshooter_api.id
  resource_id = aws_api_gateway_method.screenshooter_method_root.resource_id
  http_method = aws_api_gateway_method.screenshooter_method_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.screenshooter.invoke_arn
}

resource "aws_api_gateway_deployment" "staging_endpoint" {
  depends_on = [
    aws_api_gateway_integration.screenshooter_lambda_connection,
    aws_api_gateway_integration.screenshooter_lambda_connection_root
  ]

  rest_api_id = aws_api_gateway_rest_api.screenshooter_api.id
  stage_name  = "dev"
}

resource "aws_api_gateway_deployment" "production_endpoint" {
  depends_on = [
    aws_api_gateway_integration.screenshooter_lambda_connection,
    aws_api_gateway_integration.screenshooter_lambda_connection_root
  ]

  rest_api_id = aws_api_gateway_rest_api.screenshooter_api.id
  stage_name  = "prod"
}

# Permission to invoke
resource "aws_lambda_permission" "invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.screenshooter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.screenshooter_api.execution_arn}/*/*/*"
}

# Output
output "staging_endpoint" {
  value = aws_api_gateway_deployment.staging_endpoint.invoke_url
}

output "production_endpoint" {
  value = aws_api_gateway_deployment.production_endpoint.invoke_url
}
