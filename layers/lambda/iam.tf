
resource "aws_iam_policy" "lambda_bedrock_invocation_policy" {
  name        = "${var.environment}-${var.project}-lambda-bedrock-invoc-policy"
  path        = "/"
  description = "Gives Lambda invocation access to Bedrock foundation models"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel",
          "bedrock:ListFoundationModels"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Define IAM Role for Lambda
resource "aws_iam_role" "lambda_bedrock_invocation_role" {
  name = "${var.environment}-${var.project}-lambda-bedrock-invoc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach bedrock policy to role
resource "aws_iam_role_policy_attachment" "lambda_bedrock_policy_attachment" {
  role       = aws_iam_role.lambda_bedrock_invocation_role.name
  policy_arn = aws_iam_policy.lambda_bedrock_invocation_policy.arn
}

# Attach basic Lambda policy
resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role       = aws_iam_role.lambda_bedrock_invocation_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
