# feedback-app-gke
An app which leverages Cloud spanner, GKE, Cloud Build and other Google cloud services
## To deploy in Google cloud
1. Login to Google cloud
```bash
$ gcloud auth login 
$ gcloud auth application-default login 
$ gcloud config set project <PROJECT_ID>
```
2. Replace the project ID and bucket name in variable file in `infrastructure/terraform/variables.tf`

3. Deploy the infrastructure
```bash
$ cd infrastructure/terraform
$ terraform init
$ terraform apply
```
## To access the application
```bash
$ gcloud container clusters get-credentials my-gke-cluster --region=us-central1
$ kubectl get svc quiz-frontend -n default -ojsonpath="{.status.loadBalancer.ingress[].ip}" 
```
### Application source reference
https://www.qwiklabs.com/focuses/1107?parent=catalog
