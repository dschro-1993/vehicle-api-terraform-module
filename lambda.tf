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
          Resource = "*"
          Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
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
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*" # {STAGE}/{METHOD}/{PATH}
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
}

resource "aws_lambda_function" "api_handler" {
  function_name = "${var.app_name}-${var.env}-handler"

  handler = var.lambda_handler
  runtime = "python3.12"
  timeout = 10

  filename         = data.archive_file.archive.output_path
  source_code_hash = data.archive_file.archive.output_base64sha256

  layers = [
    "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:79",
    aws_lambda_layer_version.custom_layer.arn
  ]

  role          = aws_iam_role.iam_role.arn
  architectures = ["arm64"] # Use Graviton2

  tags = {
    APP_VERSION = var.app_version
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = merge(
      var.env_vars,
    # {...}
    )
  }

  # {...}
}
