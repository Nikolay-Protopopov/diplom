output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

output "internal_fqdns" {
  value = {
    web1    = "web-1.ru-central1.internal"
    web2    = "web-2.ru-central1.internal"
    elastic = "elastic.ru-central1.internal"
    zabbix  = "zabbix.ru-central1.internal"
    kibana  = "kibana.ru-central1.internal"
  }
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
