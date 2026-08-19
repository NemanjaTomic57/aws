#!/bin/bash

aws ec2 run-instances --region eu-central-1 \
  --image-id ami-08241d277446b81d7 \
  --instance-type t4g.small \
  --key-name aws \
  --count 1
