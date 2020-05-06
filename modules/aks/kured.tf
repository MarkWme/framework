#
# kured
#

# Based on the weaveworks/kured template here: https://github.com/weaveworks/kured/releases/download/1.2.0/kured-1.2.0-dockerhub.yaml
# More info: https://github.com/weaveworks/kured

resource "kubernetes_service_account" "kured_service_account" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  automount_service_account_token = true
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }
}

resource "kubernetes_role" "kured_role" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }
  rule { # Allow kured to lock/unlock itself
    api_groups     = ["apps"]
    resources      = ["daemonsets"]
    resource_names = ["kured"]
    verbs          = ["update", "get"]
  }
}

resource "kubernetes_cluster_role" "kured_cluster_role" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  metadata {
    name = "kured"
  }

  # #
  # Allow kured to read spec.unschedulable
  # Allow kubectl to drain/uncordon
  # #
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list", "delete", "get"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "kured_cluster_role_binding" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  metadata {
    name = "kured"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kured_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kured_service_account[0].metadata[0].name
    namespace = kubernetes_service_account.kured_service_account[0].metadata[0].namespace
  }
}

resource "kubernetes_role_binding" "kured_role_binding" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.kured_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kured_service_account[0].metadata[0].name
    namespace = kubernetes_service_account.kured_service_account[0].metadata[0].namespace
  }
}

resource "kubernetes_daemonset" "kured_daemonset" {
  count = var.enable_kured ? 1:0
  provider = kubernetes
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        name = "kured"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name = "kured"
        }
      }
      spec {
        automount_service_account_token = true
        service_account_name = kubernetes_service_account.kured_service_account[0].metadata[0].name
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
        host_pid       = true # Facilitate entering the host mount namespace via init
        restart_policy = "Always"
        container {
          name              = "kured"
          image             = "docker.io/weaveworks/kured:master-f6e4062"
          image_pull_policy = "IfNotPresent"
          security_context { # Give permission to nsenter /proc/1/ns/mnt
            privileged = true
          }
          env {
            # Pass in the name of the node on which this pod is scheduled
            # for use with drain/uncordon operations and lock acquisition
            name = "KURED_NODE_ID"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          command = ["/usr/bin/kured"]
          args = [
            "--alert-filter-regexp=^RebootRequired$",              # alert names to ignore when checking for active alerts
            "--blocking-pod-selector=runtime=long,cost=expensive", # label selector identifying pods whose presence should prevent reboots
            "--blocking-pod-selector=name=temperamental",
            "--blocking-pod-selector=...",
            "--ds-name=kured",                               # name of daemonset on which to place lock
            "--ds-namespace=kube-system",                    # namespace containing daemonset on which to place lock
            "--lock-annotation=weave.works/kured-node-lock", # annotation in which to record locking node
            "--reboot-sentinel=/var/run/reboot-required",    # path to file whose existence signals need to reboot
            "--time-zone=UTC",                               # use this timezone to calculate allowed reboot time
            "--period=1h0m0s",                               # reboot check period (default 1h0m0s)
            "--start-time=1am",          # only reboot after this time of day
            "--end-time=11pm",              # only reboot before this time of day
            #           additional configurable args
            # #            - --prometheus-url=http://prometheus.monitoring.svc.cluster.local
            # #            - --slack-hook-url=https://hooks.slack.com/...
            # #            - --slack-username=prod
            # #            - --slack-channel=xyz
          ]
        }
      }
    }
  }
}
