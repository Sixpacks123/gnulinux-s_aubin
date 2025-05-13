#!/usr/bin/env bash
# ------------------------------------------------------------
# setup.sh – Déploiement complet Exercice 2 (Caddy + Flask + Fail2ban)
# ------------------------------------------------------------
# Exécutez en root ou via sudo : ./scripts/setup.sh <domaine>
#   <domaine> : FQDN pointant vers la machine (ex. example.test)
# Si aucun domaine n'est fourni, « example.test » sera utilisé (HTTP local).
# ------------------------------------------------------------
set -euo pipefail

DOMAIN="${1:-example.test}"
APP_DIR="/opt/flaskapp"
VENV_DIR="$APP_DIR/venv"
LOG_DIR="/var/log/caddy"

log() { printf "[SETUP %s] %s\n" "$(date '+%F %T')" "$*"; }

install_packages() {
  log "Installation paquets système (Caddy, Fail2ban, Python3, virtualenv)"
  apt update -y
  apt install -y python3 python3-venv python3-pip git curl gnupg2 lsb-release fail2ban
  # Caddy repo officiel
  if ! command -v caddy &>/dev/null; then
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /usr/share/keyrings/caddy.gpg >/dev/null
    curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/deb/$(lsb_release -cs).deb.txt" \
      | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update -y && apt install -y caddy
  fi
}

setup_flask_app() {
  log "Déploiement de l'application Flask dans $APP_DIR"
  install -d -m 755 "$APP_DIR"
  # Copier main.py
  cp "$(dirname "$0")/../app/main.py" "$APP_DIR/main.py"
  # Virtualenv + dépendances
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi
  "$VENV_DIR/bin/pip" install --upgrade pip
  "$VENV_DIR/bin/pip" install flask

  # Service systemd
  cat > /etc/systemd/system/flask-app.service <<SERVICE
[Unit]
Description=Gunicorn Flask App (exercice2)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
ExecStart=$VENV_DIR/bin/gunicorn -b 127.0.0.1:5000 main:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE

  systemctl daemon-reload
  systemctl enable --now flask-app.service
}

configure_caddy() {
  log "Configuration de Caddy pour le domaine $DOMAIN"
  # Copier Caddyfile et remplacer domaine
  mkdir -p /etc/caddy
  sed "s/example.test/$DOMAIN/g" "$(dirname "$0")/../Caddyfile" > /etc/caddy/Caddyfile
  # Créer dossier log
  mkdir -p "$LOG_DIR"
  chown caddy:caddy "$LOG_DIR"
  systemctl enable --now caddy
}

configure_fail2ban() {
  log "Configuration Fail2ban (filtre + jail)"
  cp "$(dirname "$0")/../fail2ban/caddy-auth.conf" /etc/fail2ban/filter.d/caddy-auth.conf
  cp "$(dirname "$0")/../fail2ban/caddy-auth.local" /etc/fail2ban/jail.d/caddy-auth.local
  systemctl restart fail2ban
}

main() {
  install_packages
  setup_flask_app
  configure_caddy
  configure_fail2ban
  log "Installation terminée. Test : https://$DOMAIN/login"
}

main "$@"

