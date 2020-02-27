provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

data "azurerm_key_vault_secret" "ssh_key" {
  name      = var.ssh_key_name
  key_vault_id = var.key_vault_id
}

data "azurerm_kubernetes_service_versions" "kubernetes_version" {
  location = var.location
  include_preview = var.use_preview_version
}

resource "random_password" "windows_admin_password" {
  length = 16
}

module "aks_sp" {
    source = "../serviceprincipal"
    service_principal_name = format("%s-sp-%s-%s", var.environment, var.azure_region_code, var.name)
    key_vault_id = var.key_vault_id
}

resource "azurerm_subnet" "aks_subnet" {
    name = format("%s-sn-%s", var.virtual_network_name, var.name)
    resource_group_name = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    address_prefix = var.aks_subnet_address_prefix
}

resource "azurerm_subnet_route_table_association" "private-subnet-to-firewall" {
  count = var.enable_route_table ? 1 : 0
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = var.route_table_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = format("%s-ks-%s-%s", var.environment, var.azure_region_code, var.name)
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = format("%s-ks-%s-%s", var.environment, var.azure_region_code, var.name)
  kubernetes_version = data.azurerm_kubernetes_service_versions.kubernetes_version.latest_version

  enable_pod_security_policy = var.enable_pod_security_policy
  private_link_enabled = var.enable_private_link

  role_based_access_control {
    enabled = var.enable_rbac
  }

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  default_node_pool {
    name = "linux01"
    vm_size = "Standard_D2s_v3"
    type = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count = var.minimum_node_count
    max_count = var.maximum_node_count
    node_count = var.node_count
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
    }
  }

  windows_profile {
    admin_username = var.admin_username
    admin_password = random_password.windows_admin_password.result
  }


  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "azure"
    service_cidr = "10.250.0.0/16"
    dns_service_ip = "10.250.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  service_principal {
    client_id     = module.aks_sp.client_id
    client_secret = module.aks_sp.client_secret
  }

  tags = {
    deployed-by = "terraform"
    timestamp = timestamp()
  }

  lifecycle {
    ignore_changes = [
      tags["timestamp"],
      default_node_pool.0.node_count # Prevent K8s autoscaling changes from being modified by Terraform
    ]
  }
}


resource "azurerm_kubernetes_cluster_node_pool" "aks_windows" {
  count                 = var.enable_windows_containers ? 1:0
  name                  = "win01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2s_v3"
  enable_auto_scaling = var.enable_auto_scaling
  min_count = var.minimum_node_count
  max_count = var.maximum_node_count
  node_count = var.node_count
  os_type = "Windows"
  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  node_taints = ["os=windows:NoSchedule"]
  lifecycle {
    ignore_changes = [
      node_count # Prevent K8s autoscaling changes from being modified by Terraform
    ]
  }
}

resource "azurerm_key_vault_secret" "windows_admin_password" {
  count        = var.enable_windows_containers ? 1:0
  name         = format("%s-windows-admin-password", azurerm_kubernetes_cluster.aks.name)
  value        = random_password.windows_admin_password.result
  key_vault_id = var.key_vault_id
}

#
# kured
#

# Based on the weaveworks/kured template here: https://github.com/weaveworks/kured/releases/download/1.2.0/kured-1.2.0-dockerhub.yaml
# More info: https://github.com/weaveworks/kured

resource "kubernetes_service_account" "kured_service_account" {
  provider = kubernetes
  automount_service_account_token = true
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }
}

resource "kubernetes_role" "kured_role" {
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
  provider = kubernetes
  metadata {
    name = "kured"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kured_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kured_service_account.metadata[0].name
    namespace = kubernetes_service_account.kured_service_account.metadata[0].namespace
  }
}

resource "kubernetes_role_binding" "kured_role_binding" {
  provider = kubernetes
  metadata {
    name      = "kured"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.kured_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kured_service_account.metadata[0].name
    namespace = kubernetes_service_account.kured_service_account.metadata[0].namespace
  }
}

resource "kubernetes_daemonset" "kured_daemonset" {
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
        service_account_name = kubernetes_service_account.kured_service_account.metadata[0].name
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

resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
  }
}

data "helm_repository" "kedacore" {
  name = "kedacore"
  url  = "https://kedacore.github.io/charts"
}
resource "helm_release" "keda" {

    name      = "keda"
    repository = data.helm_repository.kedacore.metadata[0].name
    chart     = "kedacore/keda"

    namespace = "keda"
    depends_on = [kubernetes_namespace.keda]
}
