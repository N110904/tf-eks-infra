#!/bin/bash

# Set your desired bucket name and AWS region and account profile
BUCKET_NAME="my-tf-remote-state-958198"
REGION="us-east-1"
PROFILE="my_aws_cred"

# Create the S3 bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=us-east-1 --profile $PROFILE