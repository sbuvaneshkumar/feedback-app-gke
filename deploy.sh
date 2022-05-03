#!/bin/bash

# EVN's
PROJECT_ID=$1
BUCKET_NAME=$2

find . -type f -exec sed -i "s/PROJECTID/$PROJECT_ID/g" {} \;
sed -i "s/BUCKET_NAME/$BUCKET_NAME/g" frontend/quiz/gcp/storage.py

echo "Creating Datastore/App Engine instance"
gcloud app create --region "us-central"

echo "Creating bucket: gs://$PROJECT_ID-media"
gsutil mb gs://$PROJECT_ID-media

echo "Exporting GCLOUD_BUCKET"
export GCLOUD_BUCKET=$PROJECT_ID-media

echo "Creating quiz-account Service Account"
gcloud iam service-accounts create quiz-account --display-name "Quiz Account"
gcloud iam service-accounts keys create key.json --iam-account=quiz-account@$PROJECT_ID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=key.json

echo "Setting quiz-account IAM Role"
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:quiz-account@$PROJECT_ID.iam.gserviceaccount.com --role roles/owner

echo "Creating Cloud Pub/Sub topic"
gcloud beta pubsub topics create feedback
gcloud beta pubsub subscriptions create worker-subscription --topic feedback

echo "Creating Cloud Spanner Instance, Database, and Table"
gcloud spanner instances create quiz-instance --config=regional-us-central1 --description="Quiz instance" --nodes=1
gcloud spanner databases create quiz-database --instance quiz-instance --ddl "CREATE TABLE Feedback ( feedbackId STRING(100) NOT NULL, email STRING(100), quiz STRING(20), feedback STRING(MAX), rating INT64, score FLOAT64, timestamp INT64 ) PRIMARY KEY (feedbackId);"

echo "Creating Container Engine cluster"
gcloud container clusters create quiz-cluster --zone us-central1-a --scopes cloud-platform
gcloud container clusters get-credentials quiz-cluster --zone us-central1-a

echo "Building Containers"
gcloud builds submit --timeout=1h -t gcr.io/$PROJECT_ID/quiz-frontend ./frontend/
gcloud builds submit --timeout=1h -t gcr.io/$PROJECT_ID/quiz-backend ./backend/

echo "Deploying to Container Engine"
kubectl create -f ./frontend-deployment.yaml
kubectl create -f ./backend-deployment.yaml
kubectl create -f ./frontend-service.yaml

echo "Project ID: $PROJECT_ID"
