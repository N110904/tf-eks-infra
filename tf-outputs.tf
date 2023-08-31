output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_name" {
  description = "cluster name"
  value = aws_eks_cluster.eks_cluster.name
}