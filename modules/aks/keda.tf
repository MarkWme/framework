/*
resource "kubernetes_namespace" "keda" {
  count = var.enable_keda ? 1:0
  metadata {
    name = "keda"
  }
}

data "helm_repository" "kedacore" {
  name = "kedacore"
  url  = "https://kedacore.github.io/charts"
}

resource "helm_release" "keda" {
  count = var.enable_keda ? 1:0

    name      = "keda"
    repository = data.helm_repository.kedacore.metadata[0].name
    chart     = "kedacore/keda"

    namespace = "keda"
    depends_on = [kubernetes_namespace.keda]
}
*/