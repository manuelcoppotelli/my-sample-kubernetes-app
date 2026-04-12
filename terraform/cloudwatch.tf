# SNS Topic for ALB 5XX Alarm
resource "aws_sns_topic" "alb_5xx_alarm" {
  name = "${var.cluster_name}-alb-5xx-alarm"
}

# Lambda IAM Role
resource "aws_iam_role" "devops_agent_trigger" {
  name = "${var.cluster_name}-devops-agent-trigger"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "devops_agent_trigger_basic" {
  role       = aws_iam_role.devops_agent_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function to trigger DevOps Agent investigation
resource "aws_lambda_function" "devops_agent_trigger" {
  function_name = "${var.cluster_name}-devops-agent-trigger"
  role          = aws_iam_role.devops_agent_trigger.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  filename         = data.archive_file.devops_agent_trigger.output_path
  source_code_hash = data.archive_file.devops_agent_trigger.output_base64sha256

  environment {
    variables = {
      WEBHOOK_URL    = var.devops_agent_webhook_url
      WEBHOOK_SECRET = var.devops_agent_webhook_secret
    }
  }
}

data "archive_file" "devops_agent_trigger" {
  type        = "zip"
  output_path = "${path.module}/lambda/devops_agent_trigger.zip"

  source {
    content  = <<-EOF
const crypto = require('crypto');
const https = require('https');
const url = require('url');

exports.handler = async (event) => {
  const webhookUrl = process.env.WEBHOOK_URL;
  const webhookSecret = process.env.WEBHOOK_SECRET;

  const snsMessage = JSON.parse(event.Records[0].Sns.Message);
  const timestamp = new Date().toISOString();

  const payload = JSON.stringify({
    eventType: 'incident',
    incidentId: `alb-5xx-$${Date.now()}`,
    action: 'created',
    priority: 'HIGH',
    title: snsMessage.AlarmName || 'ALB 5XX Errors',
    description: snsMessage.AlarmDescription || 'ALB is returning 5XX errors',
    timestamp: timestamp,
    service: 'ALB',
    data: {
      metadata: {
        region: snsMessage.Region || 'unknown',
        alarmName: snsMessage.AlarmName,
        newState: snsMessage.NewStateValue,
        reason: snsMessage.NewStateReason
      }
    }
  });

  const hmac = crypto.createHmac('sha256', webhookSecret);
  hmac.update(`$${timestamp}:$${payload}`, 'utf8');
  const signature = hmac.digest('base64');

  const parsedUrl = new url.URL(webhookUrl);

  const options = {
    hostname: parsedUrl.hostname,
    path: parsedUrl.pathname,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-amzn-event-timestamp': timestamp,
      'x-amzn-event-signature': signature
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log('Response:', res.statusCode, data);
        resolve({ statusCode: res.statusCode, body: data });
      });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
};
EOF
    filename = "index.js"
  }
}

# SNS subscription for Lambda
resource "aws_sns_topic_subscription" "devops_agent_trigger" {
  topic_arn = aws_sns_topic.alb_5xx_alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.devops_agent_trigger.arn
}

# Lambda permission for SNS
resource "aws_lambda_permission" "devops_agent_trigger" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.devops_agent_trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alb_5xx_alarm.arn
}

# CloudWatch Alarm for ALB 5XX Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.cluster_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is returning 5XX errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  # Trigger DevOps Agent investigation via SNS -> Lambda -> Webhook
  alarm_actions = [aws_sns_topic.alb_5xx_alarm.arn]
}
