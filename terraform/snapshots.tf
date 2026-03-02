#################################################
# Snapshot Schedule for Diploma Infrastructure
#################################################

locals {
  snapshot_disk_ids = [
    yandex_compute_instance.web1.boot_disk[0].disk_id,
    yandex_compute_instance.web2.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
  ]
}

resource "yandex_compute_snapshot_schedule" "diploma_daily" {
  name = "diploma-daily-snapshots"

  # Every day at 03:00
  schedule_policy {
    expression = "0 3 * * *"
  }

  # Keep last 7 snapshots
  snapshot_count = 7

  snapshot_spec {
    description = "Daily snapshots for diploma infrastructure"
    labels = {
      project = "diploma"
      backup  = "daily"
    }
  }

  disk_ids = local.snapshot_disk_ids
}
