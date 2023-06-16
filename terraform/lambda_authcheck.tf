data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example_iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "example" {
  type             = "zip"
  source_file      = "lambda_code/lambda_function.py"
  output_file_mode = "0666"
  output_path      = "lambda_code/lambda_function.zip"
}

resource "aws_lambda_function" "example" {
  filename         = "./lambda_code/lambda_function.zip"
  function_name    = "example_lambda_apgw"
  role             = aws_iam_role.example_iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_code/lambda_function.zip")
  architectures    = ["arm64"]
  runtime          = "python3.9"
  layers           = []
  timeout          = 15
  depends_on       = [data.archive_file.example]
}

output "example_lambda_arn" {
  value = aws_lambda_function.example.arn
}

output "example_lambda_invoke_arn" {
  value = aws_lambda_function.example.invoke_arn
}