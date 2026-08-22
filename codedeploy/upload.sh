#!/bin/bash

tar -czvf revision.tgz appspec.yml scripts
aws s3 cp  ./revision.tgz s3://delete-codedeploy-1977

