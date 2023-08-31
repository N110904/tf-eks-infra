# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes

resource "aws_iam_role" "aws_eks_node_role" {
  name = "${var.env}-${var.eks_cluster_name}-node-role"

  assume_role_policy = <<POLICY
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
POLICY

  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_amazoneksworkernodepolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aws_eks_node_role.name

  depends_on = [ aws_iam_role.aws_eks_node_role ]
}

resource "aws_iam_role_policy_attachment" "eks_node_amazoneks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws_eks_node_role.name

  depends_on = [ aws_iam_role.aws_eks_node_role ]
}

resource "aws_iam_role_policy_attachment" "eks_node_amazonec2containerregistryreadonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aws_eks_node_role.name

  depends_on = [ aws_iam_role.aws_eks_node_role ]
}

resource "aws_eks_node_group" "eks_cluster_ng" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.env}-${var.eks_cluster_name}-node-group"
  node_role_arn   = aws_iam_role.aws_eks_node_role.arn
  subnet_ids      = aws_subnet.private_subnets[*].id
  
#   ami_type = var.node_ami_type
  capacity_type = var.node_capacity_type
  disk_size = var.node_disk_size
  instance_types = [var.node_instance_types]
  version = var.eks_version

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

#     remote_access {
#     ec2_ssh_key = "eks-terraform-key"    
#   }

  depends_on = [
    aws_iam_role.aws_eks_node_role,
    aws_eks_cluster.eks_cluster,
    aws_vpc.eks_vpc
  ]

  tags = {
    Name = "${var.env}-${var.eks_cluster_name}"
  }  
}