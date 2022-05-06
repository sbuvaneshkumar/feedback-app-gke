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
## Note
There is ongoing bug in `kubectl` terraform provider, where you might experience following error at the end of `terraform apply`.
```bash
Error: Provider produced inconsistent final plan
```
To resolve this, rerun the `terraform apply`, the second run should resolve the issue.

## TODO: Improvements
1. Create VPC and deploy the resources in dedicated network, at this moment, it is using default VPC
2. Modularize the Terraform codebase
3. Implement CI
4. Replace kubectl provider with helm and use helm charts
### Application source reference
https://www.qwiklabs.com/focuses/1107?parent=catalog
