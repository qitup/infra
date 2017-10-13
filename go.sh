#!/usr/bin/env bash

if [[ -z $1 ]]; then
    echo "Please specify the command and options to pass to docker-compose"
    exit 1
fi

if [[ -z "$ENV" ]]; then
    ENV="dev"
fi

source ~/.spotify/creds.conf

export SIGNING_KEY=$(cat ~/go/src/dubclan/api/keys/sign-${ENV})

docker-compose -p qitup -f docker-compose.yml -f ../api/docker-compose.yml "$@"