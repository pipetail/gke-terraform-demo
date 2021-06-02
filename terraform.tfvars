region   = "europe-west3"
location = "europe-west3"

project_slug = "pipetail-demo"

project                 = "pipetail-gke-terraform-demo"
environment_name_prefix = "dev-"
environment_name_suffix = "dev"

cluster_name = "cluster-1"

node_pool_default_node_count = "0"
node_pool_app_node_count     = "1"

node_pool_min_node_count = "0"
node_pool_max_node_count = "5"

node_pool_machine_type     = "e2-custom-4-8192"
node_pool_app_machine_type = "e2-custom-4-8192"

services = [
  "athena",
  "atlas",
  "argocd"
]

service_port      = 30443
service_port_name = "https"

argo_port      = 31443
argo_port_name = "argo-dev"

# # mysql
mysql_db_machine_type = "db-n1-standard-1"
name_override         = "sql-dev-1"
databases = [
  "temporal",
  "temporal_visibility"
]
