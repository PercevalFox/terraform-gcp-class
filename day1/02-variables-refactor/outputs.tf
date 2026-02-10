output "vm_name" {
  value = google_compute_instance.vm_web.name
}

output "vm_internal_ip" {
  value = google_compute_instance.vm_web.network_interface.0.network_ip
}
