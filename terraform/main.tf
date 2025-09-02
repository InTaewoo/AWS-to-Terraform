# ## 1. VPC 생성
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # DNS 호스트 이름 활성화 (EC2에 public DNS 할당)
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.my-aws}-vpc"
  }
}

# ## 2. Public Subnets 생성 (1)
# 외부 인터넷과 통신이 가능한 서브넷
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) # 변수에 정의된 CIDR 개수만큼 생성
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index] # 각 서브넷을 다른 AZ에 배치
  map_public_ip_on_launch = true # 인스턴스 생성 시 Public IP 자동 할당

  tags = {
    Name = "${var.my-aws}-public-subnet-${count.index + 1}"
  }
}

# ## 3. Private Subnets 생성 (2개)
# 외부에서 직접 접근은 불가능하지만, 내부에서 외부로 나갈 수 있는 서브넷
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.my-aws}-private-subnet-${count.index + 1}"
  }
}

# ## 사용 가능한 Availability Zones 정보 가져오기
data "aws_availability_zones" "available" {
  state = "available"
}