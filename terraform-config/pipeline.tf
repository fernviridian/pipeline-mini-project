resource "aws_iam_role" "iam_codepipeline_role" {
  name = "iam_codepipeline"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "iam_codepipeline_policy" {
  name = "iam_codepipeline_policy"
  role = "${aws_iam_role.iam_codepipeline_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:StartBuild",
                "codebuild:BatchGetBuilds"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}


resource "aws_iam_role" "iam_code_build_role" {
  name = "iam_code_build_role"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_code_build_policy" {
  name = "iam_code_build_policy"
  role = "${aws_iam_role.iam_code_build_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AccessCodePipelineArtifacts"
    },
    {
      "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AccessECR"
    },
    {
      "Action": [
          "ecr:GetAuthorizationToken"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ecrAuthorization"
    },
    {
      "Action": [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices",
          "ecs:CreateService",
          "ecs:ListServices",
          "ecs:UpdateService"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ecsAccess"
    },
    {
         "Sid":"logStream",
         "Effect":"Allow",
         "Action":[
            "logs:PutLogEvents",
            "logs:CreateLogGroup",
            "logs:CreateLogStream"
         ],
         "Resource":"arn:aws:logs:${var.aws_region}:*:*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "${aws_iam_role.iam_ecs_service_role.arn}"
    }
  ]
}
POLICY
}


# bucket to hold code pipeline metadata between stages
resource "aws_s3_bucket" "pipeline" {
  # make sure we have unique bucket name since all buckets share global namespace by using current aws account id
  bucket = "demo-pipeline-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "demo"
  role_arn = "${aws_iam_role.iam_codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.pipeline.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }
  stage {
    name = "TestDocker"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      version         = "1"
      configuration {
        ProjectName = "${aws_codebuild_project.codebuild_docker_test.name}"
      }
    }
  }

  stage {
    name = "BuildDocker"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      version         = "1"
      configuration {
        ProjectName = "${aws_codebuild_project.codebuild_docker_image.name}"
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      version         = "1"
      configuration {
        ProjectName = "${aws_codebuild_project.codebuild_deploy_on_ecs.name}"
      }
    }
  }
}

