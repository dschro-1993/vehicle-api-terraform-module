resource "null_resource" "custom_requirements" {
  # triggers = {
  #   requirements = filesha256("${var.root_path}/pyproject.toml")
  # }
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${var.root_path}/.venv
      rm -rf ${var.lambda_layer_output_path}/
      poetry install --no-dev -C ${var.root_path}
      mkdir  ${var.lambda_layer_output_path}/
      cp -rf ${var.root_path}/.venv/lib ${var.lambda_layer_output_path}/
      zip -r ${var.lambda_layer_output_file} ${var.lambda_layer_output_path}/
      rm -rf ${var.lambda_layer_output_path}/
    EOT
  }
}

resource "aws_s3_bucket" "layer_bucket" {
  bucket = "${var.app_name}-${var.env}-layer-bucket"
}

# {lifecycle-rules}
# {...}

resource "aws_s3_object" "layer_object" {
  depends_on  = [null_resource.custom_requirements]
  bucket      = aws_s3_bucket.layer_bucket.id
# source_hash = filesha256("${var.lambda_layer_output_file}")
  source      = var.lambda_layer_output_file
  key         = var.lambda_layer_output_file
}

resource "aws_lambda_layer_version" "my_layer_version" {
  layer_name               = "${var.app_name}-${var.env}-custom-layer"
  compatible_architectures = ["arm64"]
  compatible_runtimes      = ["python3.12"]
  s3_bucket                = aws_s3_bucket.layer_bucket.id
  s3_key                   = aws_s3_object.layer_object.id
}

# {...}
