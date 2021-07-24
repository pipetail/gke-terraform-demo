# gke-terraform-demo

## Terraform
To provision all the GCP resources we use [terraform](https://www.terraform.io) with [terraform Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

### Remote backend (terraform state)
We use Google Cloud Storage buckets to store and version terraform state (`*.tfstate`) for each of the environments in their own GCP project.

### bootstrapping
The bucket needs to be bootstrapped for each new environment by hand.

```
PROJECT_ID=$(gcloud config get-value project)
gsutil mb gs://${PROJECT_ID}-terraform-state
```

Enable versioning on the bucket to keep the history of your deployments.

```
gsutil versioning set on gs://${PROJECT_ID}-terraform-state
```

More details [here](https://cloud.google.com/architecture/managing-infrastructure-as-code).

In case of failure (e.g. pipeline agent hangs unexpectedly) you might need to run
```
terraform force-unlock <UUID>
```
to force-unlock the state.

### Quickstart
```
gcloud auth login && gcloud auth application-default login

cd dev
terraform init
terraform apply
```

### provider lock
```
terraform providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=darwin_arm64 -platform=windows_amd64
```
