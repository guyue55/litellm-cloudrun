#!/bin/bash
set -e

#export PROJECT_ID=eyeweb-xxx
#export REGION=us-central1

# 服务名称
export SERVICE_NAME=litellm-proxy-001

if [ ! $PROJECT_ID ]; then
    echo "please set PROJECT_ID"
    exit 1
fi

if [ ! $REGION ]; then
    echo "please set REGION"
    exit 1
fi

# 更新 secret 版本
gcloud secrets versions add litellm-config \
    --data-file="config.yaml" \
    --project=${PROJECT_ID}

# 更新 Cloud Run 服务
gcloud run services update ${SERVICE_NAME} \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --set-secrets=/secrets/config.yaml=litellm-config:latest