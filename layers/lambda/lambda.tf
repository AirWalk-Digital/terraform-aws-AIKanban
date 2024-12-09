
data "archive_file" "python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/python.zip"
}

resource "aws_lambda_function" "lambda_bedrock_invoc" {
  filename         = "${path.module}/python/python.zip"
  function_name    = "${var.environment}-${var.project}-lambda-bedrock-invoc"
  role             = aws_iam_role.lambda_bedrock_invocation_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.lambda_basic_policy_attachment, aws_iam_role_policy_attachment.lambda_bedrock_policy_attachment]
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/python/python.zip")
}
