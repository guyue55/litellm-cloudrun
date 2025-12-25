#!/bin/bash
set -e

#export PROJECT_ID=eyeweb-xxx
#export REGION=us-central1

# 服务账号名称
export SA_NAME=litellmsa
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

gcloud run services delete ${SERVICE_NAME} --project=${PROJECT_ID} --region=${REGION} --quiet

gcloud secrets delete litellm-config --project=${PROJECT_ID} --quiet

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/aiplatform.user' \
    --condition=None > /dev/null

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/secretmanager.secretAccessor' \
    --condition=None > /dev/null

gcloud iam service-accounts delete ${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --project=${PROJECT_ID} --quiet > /dev/null
