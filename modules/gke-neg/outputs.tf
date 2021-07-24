output "neg_id" {
  value = {
    for t, v in google_compute_network_endpoint_group.main :
    t => google_compute_network_endpoint_group.main[t].id
  }
}
