
data "archive_file" "python_code" {
  type        = "zip"
  source_dir  = "src/"
  output_path = "bedrock_lambda.zip"
}

resource "aws_lambda_function" "lambda_bedrock_invoc" {
  filename         = "bedrock_lambda.zip"
  function_name    = "${var.environment}-${var.project}-lambda-bedrock-invoc"
  role             = aws_iam_role.lambda_bedrock_invocation_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  depends_on       = [aws_iam_role_policy_attachment.lambda_basic_policy_attachment, aws_iam_role_policy_attachment.lambda_bedrock_policy_attachment, data.archive_file.python_code]
  timeout          = 60
  source_code_hash = data.archive_file.python_code.output_base64sha256

}
