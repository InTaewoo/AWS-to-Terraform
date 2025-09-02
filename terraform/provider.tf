# 사용할 테라폼 버전과 프로바이더를 지정합니다.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # AWS 프로바이더 버전을 5.x 버전대로 고정
    }
  }
}

# 사용할 AWS 프로바이더의 기본 설정을 정의합니다.
provider "aws" {
  region = var.aws_region
}