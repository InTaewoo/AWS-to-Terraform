# ## 4. 인터넷 게이트웨이 (IGW) 생성 및 VPC에 연결
# VPC가 외부 인터넷과 통신하기 위한 관문
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.my-aws}-igw"
  }
}

# ## 5. NAT 게이트웨이를 위한 탄력적 IP(EIP) 생성
resource "aws_eip" "nat" {
  domain = "vpc" # VPC 내에서 사용 명시
  
  tags = {
    Name = "${var.my-aws}-nat-eip"
  }
}

# ## 6. NAT 게이트웨이 생성
# Private Subnet의 인스턴스들이 외부 인터넷에 접속할 수 있도록 해줌
resource "aws_nat_gateway" "main" {
  # Public Subnet 중 첫 번째 서브넷에 배치
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "${var.my-aws}-nat-gw"
  }
  
  # IGW가 먼저 생성되어야 NAT GW가 인터넷과 통신 가능
  depends_on = [aws_internet_gateway.main]
}

# ## 7. Public 라우팅 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # 0.0.0.0/0 (모든 트래픽)을 인터넷 게이트웨이로 보냄
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.my-aws}-public-rt"
  }
}

# ## 8. Private 라우팅 테이블 생성
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # 0.0.0.0/0 (모든 트래픽)을 NAT 게이트웨이로 보냄
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.my-aws}-private-rt"
  }
}

# ## 9. 라우팅 테이블과 서브넷 연결
# Public Subnets -> Public 라우팅 테이블
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnets -> Private 라우팅 테이블
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}