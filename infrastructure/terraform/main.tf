#redddsource "google_project" "my_project" {
#  name       = "My Project"
#  project_id = "your-project-id"
#  org_id     = "1234567"
#}
data "google_project" "project" {}

output "project_number" {
  value = data.google_project.project.project_id
}

resource "google_app_engine_application" "app" {
  project     = data.google_project.project.project_id
  location_id = "us-central"
}

resource "google_storage_bucket" "auto-expire" {
  name          = var.bucket 
  location      = "US-WEST1"
  force_destroy = true
}

resource "google_service_account" "service_account" {
  account_id   = "quiz-account"
  display_name = "Quiz Account"
}

resource "google_service_account_key" "key" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/owner"

    members = [
      "serviceAccount:quiz-account@${data.google_project.project.project_id}.iam.gserviceaccount.com",
    ]
  }
}

resource "google_pubsub_topic" "feedback" {
  name = "feedback"
}

resource "google_pubsub_subscription" "worker-subscription" {
  name  = "worker-subscription"
  topic = google_pubsub_topic.feedback.name

  ack_deadline_seconds = 20
}

resource "google_spanner_instance" "quiz-instance" {
  config       = "regional-us-central1"
  display_name = "Quiz instance"
  num_nodes    = 1
}

resource "google_spanner_database" "quiz-database" {
  instance = google_spanner_instance.quiz-instance.name
  name     = "quiz-database"
  ddl = [
    "CREATE TABLE Feedback ( feedbackId STRING(100) NOT NULL, email STRING(100), quiz STRING(20), feedback STRING(MAX), rating INT64, score FLOAT64, timestamp INT64 ) PRIMARY KEY (feedbackId)",
  ]
  deletion_protection = false
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1"
  min_master_version = "1.19"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# resource "google_cloudbuild_trigger" "cloudbuild" {
#   name        = "cloudbuild"
#   description = "run terraform plan/apply"
#   filename = "./frontend"
# 
#   build {
#    step {
#      name = "gcr.io/${var.project}/quiz-frontend"
#      timeout = "1h"
#    }
# }
# }

resource "null_resource" "build_image_frontend" {
  provisioner "local-exec" {
  command = "find ../../application/frontend  -type f -exec sed -i 's/PROJECTID/${var.project}/g' {} \\; && sed -i 's/PROJECTID/${var.project}/g' ../k8s/frontend-deployment.yaml ../k8s/backend-deployment.yaml  &&  sed -i 's/BUCKET_NAME/${var.bucket}/g' ../../application/frontend/quiz/gcp/storage.py && gcloud builds submit --timeout=1h -t gcr.io/${var.project}/quiz-frontend ../../application/frontend/"
 }
}

resource "null_resource" "build_image_backend" {
  provisioner "local-exec" {
  command = "find ../../application/backend -type f -exec sed -i 's/PROJECTID/${var.project}/g' {} \\; && gcloud builds submit --timeout=1h -t gcr.io/${var.project}/quiz-backend ../../application/backend/"
 }
}
