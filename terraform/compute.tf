data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

locals {
  cores       = 2
  memory      = 2
  disk_gb     = 10
  core_frac   = 20
  platform_id = "standard-v3" # Ice Lake
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = local.platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = local.cores
    memory        = local.memory
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.disk_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  platform_id = local.platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = local.cores
    memory        = 4
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.disk_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = local.platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = local.cores
    memory        = local.memory
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.disk_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  platform_id = local.platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = local.cores
    memory        = 4
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elastic.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "web1" {
  name        = "web-1"
  hostname    = "web-1"
  platform_id = local.platform_id
  zone        = "ru-central1-a"

  resources {
    cores         = local.cores
    memory        = local.memory
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.disk_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "yandex_compute_instance" "web2" {
  name        = "web-2"
  hostname    = "web-2"
  platform_id = local.platform_id
  zone        = "ru-central1-b"

  resources {
    cores         = local.cores
    memory        = local.memory
    core_fraction = local.core_frac
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = local.disk_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
