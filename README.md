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
## Deploy to Google cloud
```bash
$ bash deploy.sh <PROJECT-ID> <BUCKET-NAME> 
```
## To access the application
```bash
$ gcloud container clusters get-credentials quiz-cluster --region=us-central1-a
$ kubectl get svc test -n default -ojsonpath="{.status.loadBalancer.ingress[].ip}"      
34.71.195.172         
```
## Local Development
The apps can be deployed locally by leveraging cloud spanner emulator.
For reference: https://cloud.google.com/spanner/docs/emulator 

### Reference
https://www.qwiklabs.com/catalog_lab/978 
