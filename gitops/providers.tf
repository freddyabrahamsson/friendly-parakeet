provider "kubernetes" {
  host                   = local.kube_cluster.server
  token                  = local.kube_user.token
  cluster_ca_certificate = base64decode(local.kube_cluster["certificate-authority-data"])
}

provider "helm" {
  kubernetes = {
    host                   = local.kube_cluster.server
    token                  = local.kube_user.token
    cluster_ca_certificate = base64decode(local.kube_cluster["certificate-authority-data"])
  }
}
