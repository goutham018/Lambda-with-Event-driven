variable "apigateway-stage-name" {
  description = "The  Stage name."
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}

 
variable "lambda_function_name" {
  description = "The Lambda function name."
  type        = string
}