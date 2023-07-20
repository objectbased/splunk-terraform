# IAM Role

resource "aws_iam_instance_profile" "splunk_single_node" {
  name = "splunk_single_node"
  role = aws_iam_role.splunk_single_node.name
}

resource "aws_iam_role" "splunk_single_node" {
  name               = "splunk_single_node"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach SSM policy for access

resource "aws_iam_role_policy_attachment" "splunk_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.splunk_single_node.name
}