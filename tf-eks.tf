# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

resource "aws_iam_role" "aws_eks_cluster_role" {
  name = "${var.env}-${var.eks_cluster_name}-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_amazoneksclusterpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws_eks_cluster_role.name

  depends_on = [ aws_iam_role.aws_eks_cluster_role ]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_amazoneksvpcresourcecontroller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.aws_eks_cluster_role.name

  depends_on = [ aws_iam_role.aws_eks_cluster_role ]
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.env}-${var.eks_cluster_name}"
  description = "SG for EKS Cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  // Ingress rule for port 80 (HTTP) to communicate with EKS cluster
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Ingress rule for port 443 (HTTPS) to communicate with EKS cluster
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  //Egress rule for Cluster to communicate with worker nodes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }

  depends_on = [ aws_vpc.eks_vpc ]
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.env}-${var.eks_cluster_name}"
  role_arn = aws_iam_role.aws_eks_cluster_role.arn
  version = var.eks_version

  ##Need to work on this
  # kubernetes_network_config {
  #   ip_family = ipv4
  #   service_ipv4_cidr = 
  # }
  
  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    subnet_ids         = aws_subnet.private_subnets[*].id
    endpoint_private_access = true
    endpoint_public_access = true
  }

  # # Enable EKS Cluster Control Plane Logging
  # enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role.aws_eks_cluster_role,
    aws_vpc.eks_vpc,
    aws_security_group.eks_cluster_sg
  ]

    tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}
