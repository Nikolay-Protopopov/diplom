# SG для bastion: только SSH от admin_cidr
resource "yandex_vpc_security_group" "bastion" {
  name       = "sg-bastion"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from admin"
    v4_cidr_blocks = [var.admin_cidr]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG для ALB: принимает HTTP из интернета
resource "yandex_vpc_security_group" "alb" {
  name       = "sg-alb"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP from Internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol          = "ANY"
    description       = "YC ALB health checks (well-known ranges)"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol          = "TCP"
    description       = "ALB health checks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG для web: HTTP только от ALB, SSH только от bastion, агент zabbix наружу, filebeat наружу
resource "yandex_vpc_security_group" "web" {
  name       = "sg-web"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol          = "TCP"
    description       = "HTTP from ALB"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }

  ingress {
    protocol          = "ANY"
    description       = "YC ALB health checks to web (well-known ranges)"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  ingress {
    protocol          = "TCP"
    description       = "ALB health checks to web"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }


  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG для Zabbix: UI только для admin_cidr, порт 10051 доступен от web+elastic+kibana+bastion 
resource "yandex_vpc_security_group" "zabbix" {
  name       = "sg-zabbix"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "Zabbix UI (HTTP) from admin"
    v4_cidr_blocks = [var.admin_cidr]
    port           = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "Zabbix server from internal hosts"
    port              = 10051
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from admin (optional). Лучше через bastion, но UI-вм в public."
    v4_cidr_blocks = [var.admin_cidr]
    port           = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }


  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG для Kibana: UI только для admin_cidr, SSH только для admin_cidr 
resource "yandex_vpc_security_group" "kibana" {
  name       = "sg-kibana"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "Kibana UI from admin"
    v4_cidr_blocks = [var.admin_cidr]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH from admin"
    v4_cidr_blocks = [var.admin_cidr]
    port           = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
    port              = 22
  }


  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG для Elasticsearch: доступ 9200 только от web и kibana, SSH только от bastion
resource "yandex_vpc_security_group" "elastic" {
  name       = "sg-elastic"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol          = "TCP"
    description       = "Elasticsearch from web (filebeat)"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    protocol          = "TCP"
    description       = "Elasticsearch from Kibana"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
