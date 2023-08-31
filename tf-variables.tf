variable "profile" {
    default = "my_aws_cred"
    description = "AWS profile for credentials"
}

variable "region" {
  default = "us-east-1"
  description = "aws region"
}

variable "env" {
  default = "dev"
  description = "environment name"
}

variable "eks_cluster_name" {
  default = "eks-cluster"
  description = "EKS cluster name"
}

##Variables block for Node group
variable "node_ami_type"{
  default = "ami-04e35eeae7a7c5883"
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node "
}

variable "node_capacity_type" {
  default = "ON_DEMAND"
  description = "Type of capacity associated with the EKS Node"
}

variable "node_disk_size" {
  default = "20"
  description = "Disk size in GiB for worker nodes"
}

variable "node_instance_types" {
  default = "t2.medium"
  description = "Instance types associated with the EKS Node"
}

variable "eks_version"{
  default = "1.26"
  description = "Kubernetes version"
}