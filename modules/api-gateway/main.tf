resource "aws_api_gateway_rest_api" "rest-api-gateway" {
  name = "api-clients"
}

resource "aws_api_gateway_resource" "gateway-resource" {
  rest_api_id = aws_api_gateway_rest_api.rest-api-gateway.id
  parent_id   = aws_api_gateway_rest_api.rest-api-gateway.root_resource_id
  path_part   = "resource"
}

resource "aws_api_gateway_method" "api-gateway" {
  rest_api_id   = aws_api_gateway_rest_api.rest-api-gateway.id
  resource_id   = aws_api_gateway_resource.gateway-resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.rest-api-gateway.id
  resource_id             = aws_api_gateway_resource.gateway-resource.id
  http_method             = aws_api_gateway_method.api-gateway.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "lambda-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest-api-gateway.execution_arn}/*/POST/resource"
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = var.apigateway-stage-name
  rest_api_id   = aws_api_gateway_rest_api.rest-api-gateway.id
  deployment_id = aws_api_gateway_deployment.gateway-deployment.id

}

resource "aws_api_gateway_deployment" "gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest-api-gateway.id
  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method.api-gateway
  ]
}


output "api_gateway_url" {
  value = aws_api_gateway_deployment.gateway-deployment.invoke_url
}
