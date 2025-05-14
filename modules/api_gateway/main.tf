resource "aws_api_gateway_rest_api" "this" {
  name = "myApi_SQS"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "resource"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/resource"
}
 
# Add Stage to the API Gateway
resource "aws_api_gateway_stage" "this" {
  stage_name    = var.api_gateway_stage_name  # e.g., "dev" or "prod"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id  # Reference to the deployment

}
 
# Create a deployment resource
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  depends_on  = [
    aws_api_gateway_integration.this,   # Make sure integration is created first
    aws_api_gateway_method.this         # Make sure method is created first
  ]
}


output "api_gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
