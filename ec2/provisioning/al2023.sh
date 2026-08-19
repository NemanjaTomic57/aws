#!/bin/bash

aws ec2 run-instances --region eu-central-1 \
  --image-id ami-043e4ca164edb8bd5 \
  --instance-type t4g.small \
  --key-name aws \
  --count 1
