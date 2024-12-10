
# -------- lambda -----------

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

# Allow access from API gateway
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_bedrock_invoc.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}

# --------- API gateway -----------

resource "aws_iam_role" "apigateway_cloudwatch_role" {
  name        = "${var.environment}-${var.project}-apigw-cw-role"
  path        = "/"
  description = "Gives API gateway write access to cloudwatch logs"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "apigateway.amazonaws.com"
            ]
          },
          "Action" : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "apigateway_cw_attachment" {
  role       = aws_iam_role.apigateway_cloudwatch_role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

