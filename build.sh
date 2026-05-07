#!/bin/bash

ENV=$1

ACCOUNT_ID=082319703342
REGION=us-east-1

IMAGE_URI=082319703342.dkr.ecr.us-east-1.amazonaws.com/$ENV

docker build -t react-app .

docker tag react-app:latest $IMAGE_URI:latest
