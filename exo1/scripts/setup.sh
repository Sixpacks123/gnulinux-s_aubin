#!/usr/bin/env bash
# ------------------------------------------------------------
# setup.sh – Déployer l'environnement RGPD sur une Debian neuve
# ------------------------------------------------------------
# * Crée la base + données de test
# * Installe scripts dans /opt/rgpd
# * Ajoute la crontab /etc/cron.d/rgpd
# ------------------------------------------------------------
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { printf "[SETUP %s] %s\n" "$(date '+%F %T')" "$*"; }

log "Installation du schéma + jeux de données"
mysql < "$ROOT_DIR/../sql/create_schema.sql"
mysql < "$ROOT_DIR/../sql/sample_data.sql"

log "Installation des scripts dans /opt/rgpd"
sudo install -Dm755 "$ROOT_DIR/anonymize_archive.sh" /opt/rgpd/anonymize_archive.sh
sudo install -Dm755 "$ROOT_DIR/generate_report.sh"   /opt/rgpd/generate_report.sh

log "Création du répertoire de rapports (/srv/reports)"
sudo mkdir -p /srv/reports
sudo chown "$(whoami)" /srv/reports

log "Déploiement de la crontab /etc/cron.d/rgpd"
cronfile=$(mktemp)
cat > "$cronfile" <<'CRON'
# Archivage + anonymisation nocturne
30 2 * * * root /opt/rgpd/anonymize_archive.sh >> /var/log/rgpd.log 2>&1
# Rapport annuel (22/12 04:00)
0 4 22 12 * root /opt/rgpd/generate_report.sh > /srv/reports/rapport-$(date +\%Y).txt
CRON
sudo install -m644 "$cronfile" /etc/cron.d/rgpd
rm "$cronfile"

log "Installation terminée. Vérifiez la base de données puis la crontab avec : sudo crontab -l -u root"

