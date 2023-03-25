resource "aws_iam_role" "iam_role" {
  name = "${var.app_name}-${var.env}-role"
  path = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
      }
    ]
  })
  inline_policy {
    name = "${var.app_name}-${var.env}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Resource = aws_dynamodb_table.dynamodb_table.arn
          Action   = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem"]
          Effect   = "Allow"
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "cwl_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "archive" {
  type        = "zip"
  output_path = "archive.zip"
  source_dir  = var.code_path
}

resource "aws_lambda_permission" "lambda_permission" {
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*" # STAGE/METHOD/PATH
  function_name = aws_lambda_function.api_resolver.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
}

data "aws_region" "current" {}

# https://awslabs.github.io/aws-lambda-powertools-python/2.10.0/core/event_handler/api_gateway/
resource "aws_lambda_function" "api_resolver" {
  function_name = "${var.app_name}-${var.env}-resolver"

  handler = var.app_handler
  runtime = "python3.9"
  timeout = 10

  filename         = data.archive_file.archive.output_path
  source_code_hash = data.archive_file.archive.output_base64sha256

  layers = [
    "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:22"
  ]

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_table.id # Todo
    }
  }

  role          = aws_iam_role.iam_role.arn
  architectures = ["arm64"] # Use Graviton2

  tags = {
    app_version = var.app_version
  }
}
