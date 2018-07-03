resource "aws_api_gateway_rest_api" "redirector_api" {
  name        = "APIGateway${var.redirector_lambda_name}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.redirector_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.redirector_api.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.redirector.invoke_arn}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.redirector_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.redirector.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.redirector_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "GET"
  authorization = "NONE"
}

// From https://github.com/hashicorp/terraform/issues/10157#issuecomment-263560025
//resource "aws_api_gateway_method_response" "method_response_proxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
//  resource_id = "${aws_api_gateway_resource.proxy.id}"
//  http_method = "${aws_api_gateway_method.proxy.http_method}"
//  status_code = "302"
//
//  response_models = {
//    "application/json" = "Empty"
//  }
//}

// From https://github.com/hashicorp/terraform/issues/10157#issuecomment-263560025
//resource "aws_api_gateway_method_response" "method_response_proxy_root" {
//  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
//  resource_id = "${aws_api_gateway_rest_api.redirector_api.root_resource_id}"
//  http_method = "${aws_api_gateway_method.proxy_root.http_method}"
//  status_code = "302"
//
//  response_models = {
//    "application/json" = "Empty"
//  }
//}

// From https://github.com/hashicorp/terraform/issues/10157#issuecomment-263560025
//resource "aws_api_gateway_integration_response" "integration_response_proxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
//  resource_id = "${aws_api_gateway_resource.proxy.id}"
//  http_method = "${aws_api_gateway_method.proxy.http_method}"
//  status_code = "302"
//
//  response_templates = {
//    "application/json" = ""
//  }
//}

// From https://github.com/hashicorp/terraform/issues/10157#issuecomment-263560025
//resource "aws_api_gateway_integration_response" "integration_response_proxy_root" {
//  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
//  resource_id = "${aws_api_gateway_rest_api.redirector_api.root_resource_id}"
//  http_method = "${aws_api_gateway_method.proxy_root.http_method}"
//  status_code = "302"
//
//  response_templates = {
//    "application/json" = ""
//  }
//}

resource "aws_api_gateway_deployment" "redirector_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_root",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.redirector_api.id}"
  stage_name  = "test"
}

resource "aws_lambda_permission" "lambda_api" {
  depends_on = [
    "aws_lambda_function.redirector",
    "aws_api_gateway_rest_api.redirector_api",
    "aws_api_gateway_method.proxy_root"
  ]
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.redirector.function_name}"
  principal = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "lambda_api_method" {
  depends_on = [
    "aws_lambda_function.redirector",
    "aws_api_gateway_rest_api.redirector_api",
    "aws_api_gateway_method.proxy_root"
  ]
  statement_id = "AllowExecutionFromAPIGatewayMethod"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.redirector.function_name}"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.redirector_api.id}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.redirector_deployment.invoke_url}"
}
