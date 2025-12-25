#!/bin/bash

# ================= 配置区域 =================

# 填写你的 GCP 项目 ID 和 区域
#export PROJECT_ID=eyeweb-xxx
#export REGION=us-central1

# 填写你的 Gemini API Key
# export MY_GEMINI_KEY="xxx"

# 填写镜像
export IMAGE=docker.io/litellm/litellm:v1.80.8-stable.1

# 设置 Master Key (客户端调用代理时的密码，如 sk-123456)，当做 api key
export MY_MASTER_KEY="${MY_MASTER_KEY:-sk-123456}"

if [ ! $PROJECT_ID ]; then
    echo "please set PROJECT_ID"
    exit 1
fi

if [ ! $REGION ]; then
    echo "please set REGION"
    exit 1
fi


if [ ! $MY_GEMINI_KEY ]; then
    echo "please set MY_GEMINI_KEY"
    exit 1
fi

# Set the project for all subsequent gcloud commands
gcloud config set project $PROJECT_ID

# echo "Create service account for litellm proxy ... "
# gcloud iam service-accounts create litellmsa \
#     --description="Service account for litellm" \
#     --display-name="litellmsa" \
#     --project=${PROJECT_ID}

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member=serviceAccount:litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
#     --role='roles/aiplatform.user'  \
#     --condition=None \
#     --quiet > /dev/null

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member=serviceAccount:litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
#     --role='roles/secretmanager.secretAccessor' \
#     --condition=None \
#     --quiet > /dev/null

echo "Create secret from your config.yaml"
gcloud secrets create litellm-config \
    --replication-policy="automatic" \
    --data-file="config.yaml"

# echo "Delete existing service ... "
# gcloud run services delete litellm-proxy-001 --region=${REGION} --quiet

echo "Deploy litellm proxy on CLoud Run"
gcloud run deploy litellm-proxy-001 --image=${IMAGE} \
    --max-instances=8 \
    --min-instances=1 \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --service-account litellmsa@${PROJECT_ID}.iam.gserviceaccount.com \
    --cpu=1 \
    --memory=512Mi \
    --concurrency=4 \
    --port=4000 \
    --allow-unauthenticated \
    --timeout=90 \
    --update-secrets=/secrets/config.yaml=litellm-config:latest \
    --set-env-vars "GEMINI_API_KEY=${MY_GEMINI_KEY},LITELLM_MASTER_KEY=${MY_MASTER_KEY}" \
    --args="--config","/secrets/config.yaml"

# #echo "Allow public access"
# gcloud run services add-iam-policy-binding --region=${REGION} --project=${PROJECT_ID} --member=allUsers --role=roles/run.invoker litellm-proxy-001

# gcloud secrets versions add litellm-config --data-file="config.yaml" --project=${PROJECT_ID}
# gcloud run services update litellm-proxy-001 --region=${REGION} --project=${PROJECT_ID} --set-secrets=/app/config.yaml=litellm-config:latest
