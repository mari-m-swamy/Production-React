#!/bin/bash

ENV=$1

ACCOUNT_ID=082319703342
REGION=us-east-1

if [ "$ENV" == "dev" ]; then

    IMAGE_URI=public.ecr.aws/i8f1i9q3/dev:latest

    aws ecr-public get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin public.ecr.aws

else

    IMAGE_URI=082319703342.dkr.ecr.us-east-1.amazonaws.com/prod:latest

    aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    082319703342.dkr.ecr.us-east-1.amazonaws.com
fi

echo "Pulling latest image..."
docker pull $IMAGE_URI

echo "Stopping old container..."
docker stop react-container || true

echo "Removing old container..."
docker rm react-container || true

echo "Removing unused images..."
docker image prune -f

echo "Starting new container..."
docker run -d \
  --name react-container \
  -p 80:80 \
  --restart always \
  $IMAGE_URI

echo "Deployment completed successfully"
