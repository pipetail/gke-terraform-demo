region   = "us-east1"
location = "us-east1"
zones    = ["us-east1-b", "us-east1-c", "us-east1-d"]

project_slug = "pt"

project                 = "pipetail-gke-terraform-demo"
environment_name_prefix = "dev-"
environment_name_suffix = "dev"

dns_zone_suffix = "gke-demo.pipetail.cloud"

notification_emails = ["marek.bartik@pipetail.io"]
