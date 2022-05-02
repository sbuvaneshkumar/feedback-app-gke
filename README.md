# Feedback app
## Prerequisite 
1. Login to Google cloud account
```bash
$ gcloud auth login 
$ gcloud auth application-default login
$ gcloud config set project <PROJECT-ID>
```
2. Create Google cloud storage bucket
```bash
$ gsutil mb gs://<BUCKET-NAME>
```
## Deployment to Google cloud
```bash
$ bash deploy.sh <PROJECT-ID> <BUCKET-NAME> 
```
## To access the application
```bash
$ gcloud container clusters get-credentials quiz-cluster --region=us-central1-a
$ kubectl get svc test -n default -ojsonpath="{.status.loadBalancer.ingress[].ip}"      
34.71.195.172         
```
