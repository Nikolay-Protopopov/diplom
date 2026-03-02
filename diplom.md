### Дипломная работа профессии Системный администратор Протопопов Николай


## Общая архитектура

В рамках дипломной работы была разработана отказоустойчивая
инфраструктура веб-сайта в облаке **Yandex Cloud**.

Основной задачей являлось создание системы, обеспечивающей:

-   высокую доступность сайта
-   централизованный мониторинг
-   сбор логов
-   резервное копирование данных

Управление инфраструктурой осуществляется с отдельной виртуальной машины
под управлением **Ubuntu 24.04**, на которой установлены:

-   Terraform
-   Ansible
-   Yandex Cloud CLI
-   Docker
-   Python virtual environment

Terraform используется для создания облачной инфраструктуры, а Ansible
--- для автоматической настройки серверов.

------------------------------------------------------------------------

## Сетевая архитектура

CIDR сети:

10.10.0.0/16

Подсети:

  Подсеть            Назначение          CIDR
  ------------------ ------------------- --------------
  Public subnet      Публичные сервисы   10.10.0.0/24
  Private subnet A   Web и Elastic       10.10.1.0/24
  Private subnet B   Резервный Web       10.10.2.0/24

Публичный доступ:

-   Bastion host
-   Application Load Balancer
-   Zabbix
-   Kibana

Web и Elasticsearch работают во внутренней сети.

Используется NAT Gateway.

------------------------------------------------------------------------

## Bastion Host

Доступ только:

37.230.147.0/24

Подключение:

ssh web-1.ru-central1.internal ssh elastic.ru-central1.internal ssh
kibana.ru-central1.internal ssh zabbix.ru-central1.internal

------------------------------------------------------------------------

## Web серверы

-   web-1.ru-central1.internal
-   web-2.ru-central1.internal

Особенности:

-   разные подсети
-   без публичных IP
-   nginx
-   статический сайт

------------------------------------------------------------------------

## Load Balancer

web-alb

158.160.223.111

Health checks:

HTTP / port 80

------------------------------------------------------------------------

## Мониторинг

Zabbix Docker:
http://158.160.50.27 
-   PostgreSQL
-   Zabbix Server
-   Zabbix Web

Мониторинг:

-   web-1
-   web-2
-   elastic
-   kibana
-   zabbix

Template:

Linux by Zabbix agent

Dashboard:

Diploma Infrastructure

------------------------------------------------------------------------

## ELK
http://130.193.39.15:5601 
### Elasticsearch

elastic.ru-central1.internal

### Kibana

kibana.ru-central1.internal

Port:

5601

### Filebeat

Logs:

/var/log/nginx/access.log /var/log/nginx/error.log

Index:

filebeat-\*

------------------------------------------------------------------------

## Backup

Snapshots:

03:00 daily

Retention:

7 copies

Servers:

-   web-1
-   web-2
-   elastic
-   zabbix

------------------------------------------------------------------------

## Security

Разрешено:

-   SSH bastion
-   HTTP Load Balancer
-   Internal Zabbix
-   Internal Elasticsearch

Запрещено:

-   Internet → Private

------------------------------------------------------------------------

## FQDN

\*.ru-central1.internal

IP не используются.

------------------------------------------------------------------------

## Отказоустойчивость

-   2 web servers
-   zones
-   Load Balancer
-   Zabbix
-   backups
-   logs

------------------------------------------------------------------------

## Automation

### Terraform

-   network
-   subnets
-   VMs
-   LB
-   SG
-   snapshots

### Ansible

-   nginx
-   docker
-   zabbix
-   elastic
-   kibana
-   filebeat

------------------------------------------------------------------------
### Логическая схема инфраструктуры
<pre>Internet
                        |
                158.160.223.111
               Application Load Balancer
                        |
          ----------------------------------
          |                                |
  web-1.ru-central1.internal      web-2.ru-central1.internal
       10.10.1.x                       10.10.2.x

          ----------- Private Network -------
                         10.10.0.0/16
                               |

 Bastion      Elastic      Kibana      Zabbix
10.10.0.x    10.10.1.x    10.10.0.x   10.10.0.x
Public IP    Private IP   Public IP   Public IP
</pre>

### Схема доступа администрирования
<pre>Администратор
    |
    | SSH
    |
Bastion Host
158.160.50.70
    |
    | ProxyJump
    |

web1 web2 elastic kibana zabbix

### Схема сбора логов
web-1          web-2
Filebeat       Filebeat
   |              |
   | logs         | logs
   ---------------
        |
   Elasticsearch
elastic.ru-central1.internal
        |
      Kibana
kibana.ru-central1.internal
</pre>

### Схема мониторинга

<pre>Zabbix Server
zabbix.ru-central1.internal
        |

web1 web2 elastic kibana zabbix

### Схема резервного копирования

Snapshot Schedule
        |

web1 web2 elastic zabbix
disk disk  disk     disk</pre>

### Схема сетевой безопасности

<pre>Разрешено:

Internet → Load Balancer → Web Servers
Internet → Bastion → Private Servers
Private → Elasticsearch
Private → Zabbix

Запрещено:

Internet → Web Servers
Internet → Elasticsearch
Internet → Private Network</pre>


## Итог

Реализовано:

-   отказоустойчивый веб-кластер
-   балансировка
-   мониторинг
-   логи
-   backup
-   automation
