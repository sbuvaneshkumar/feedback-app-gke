resource "kubectl_manifest" "frontend_deploy" {
  yaml_body  = file("../k8s/frontend-deployment.yaml")
  depends_on = [google_container_cluster.primary,null_resource.build_image_frontend,null_resource.build_image_backend]
}

resource "kubectl_manifest" "backend_deploy" {
  yaml_body  = file("../k8s/backend-deployment.yaml")
  depends_on = [google_container_cluster.primary,null_resource.build_image_frontend,null_resource.build_image_backend]
}

resource "kubectl_manifest" "frontend_svc" {
  yaml_body  = file("../k8s/frontend-service.yaml")
  depends_on = [google_container_cluster.primary,null_resource.build_image_frontend,null_resource.build_image_backend]
}
