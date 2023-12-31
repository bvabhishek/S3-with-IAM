provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "SeaSidesbucket" {
  depends_on = [
    aws_iam_user.user_one,
    aws_iam_user.user_two,
    aws_iam_user.user_three,
    aws_iam_user.user_four
  ]
  bucket = "ss-s3-iam-${random_string.random_name.result}"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "SeaSidesbucket" {
  bucket                  = aws_s3_bucket.SeaSidesbucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.SeaSidesbucket.bucket
  key    = "ss.mp4"
  source = "ss.mp4"
}

resource "aws_s3_bucket_policy" "policy_for_all_four_users" {
  bucket = aws_s3_bucket.SeaSidesbucket.bucket
  policy = jsonencode({
    "Id": "Policy1673500007883",
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "StmtAllowUserTwoAndThree",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.SeaSidesbucket.arn}",
          "${aws_s3_bucket.SeaSidesbucket.arn}/*"
        ],
        "Principal": {
          "AWS": [
            "${aws_iam_user.user_two.arn}",
            "${aws_iam_user.user_three.arn}"
          ]
        }
      },
      {
        "Sid": "StmtDenyUserOne",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": "${aws_s3_bucket.SeaSidesbucket.arn}/*",
        "Principal": {
          "AWS": "${aws_iam_user.user_one.arn}"
        }
      },
      {
        "Sid": "StmtAllowUserFour",
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "${aws_s3_bucket.SeaSidesbucket.arn}",
        "Principal": {
          "AWS": "${aws_iam_user.user_four.arn}"
        }
      }
    ]
  })
}
