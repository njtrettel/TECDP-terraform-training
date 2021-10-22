resource "aws_sns_topic" "my_topic" {
    name = "YOUR_NAME-sns-dev"
}

resource "aws_sqs_queue" "my_queue" {
    name = "YOUR_NAME-sqs-dev"
}