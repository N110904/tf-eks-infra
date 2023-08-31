#!/bin/bash

# Set your bucket name, AWS region and profile
BUCKET_NAME="my-tf-remote-state-958198"
REGION="us-east-1"
PROFILE="my_aws_cred"

# Delete all objects in the bucket
aws s3 rm s3://$BUCKET_NAME --recursive --profile $PROFILE

# Delete the S3 bucket
aws s3api delete-bucket --bucket $BUCKET_NAME --region $REGION --profile $PROFILE