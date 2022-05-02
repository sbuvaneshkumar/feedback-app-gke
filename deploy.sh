#!/bin/bash

# EVN's
# PROJECTID
PROJECTID=$1
BUCKET_NAME=$2

find . -type f -exec sed -i "s/PROJECTID/$PROJECTID/g" {} \;
sed -i "s/BUCKET_NAME/$BUCKET_NAME/g" frontend/quiz/gcp/storage.py

echo "Creating Datastore/App Engine instance"
gcloud app create --region "us-central"

echo "Creating bucket: gs://$PROJECTID-media"
gsutil mb gs://$PROJECTID-media

echo "Exporting PROJECTID and GCLOUD_BUCKET"
export PROJECTID=$PROJECTID
export GCLOUD_BUCKET=$PROJECTID-media

echo "Creating virtual environment"
mkdir ~/venvs
virtualenv ~/venvs/developingapps
source ~/venvs/developingapps/bin/activate

echo "Installing Python libraries"
pip install --upgrade pip
pip install -r requirements.txt

echo "Creating Datastore entities"
python add_entities.py

echo "Creating quiz-account Service Account"
gcloud iam service-accounts create quiz-account --display-name "Quiz Account"
gcloud iam service-accounts keys create key.json --iam-account=quiz-account@$PROJECTID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=key.json

echo "Setting quiz-account IAM Role"
gcloud projects add-iam-policy-binding $PROJECTID --member serviceAccount:quiz-account@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/owner

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
gcloud builds submit --timeout=1h -t gcr.io/$PROJECTID/quiz-frontend ./frontend/
gcloud builds submit --timeout=1h -t gcr.io/$PROJECTID/quiz-backend ./backend/

echo "Deploying to Container Engine"
sed -i -e "s/\[PROJECTID\]/$PROJECTID/g" ./frontend-deployment.yaml
sed -i -e "s/\[PROJECTID\]/$PROJECTID/g" ./backend-deployment.yaml
kubectl create -f ./frontend-deployment.yaml
kubectl create -f ./backend-deployment.yaml
kubectl create -f ./frontend-service.yaml

echo "Project ID: $PROJECTID"
