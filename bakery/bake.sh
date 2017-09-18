#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
iam_identity=$(aws sts get-caller-identity | jq -r '.Arn')
packer build -var "iam_identity=$iam_identity" $DIR/base-1604.json
