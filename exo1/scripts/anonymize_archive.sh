#!/usr/bin/env bash
# ------------------------------------------------------------
# anonymize_archive.sh – Archiver et anonymiser les clients
# inactifs depuis plus de 3 ans ainsi que leurs factures.
# ------------------------------------------------------------
# Usage : exécuté par cron ou manuellement (root)
# Dépendances : mysql-client, droits root ou équivalent sudo
# ------------------------------------------------------------
set -euo pipefail

# ----- Paramètres modifiables --------------------------------
PROD_DB="prod"             # Schéma de production
ARCHIVE_DB="archive"       # Schéma d'archivage intermédiaire
CUTOFF="DATE_SUB(CURDATE(), INTERVAL 3 YEAR)"  # Point de bascule
MYSQL_USER="root"          # Compte MySQL disposant des droits
# ------------------------------------------------------------

log() { printf "[%s] %s\n" "$(date '+%F %T')" "$*"; }

log "Début du script : archivage + anonymisation (>3 ans)"

mysql --user="$MYSQL_USER" <<SQL
-- 1) S'assurer que le schéma d'archive existe
CREATE DATABASE IF NOT EXISTS \`$ARCHIVE_DB\`;

-- 2) Créer les tables miroir si nécessaire
CREATE TABLE IF NOT EXISTS \`$ARCHIVE_DB\`.clients  LIKE \`$PROD_DB\`.clients;
CREATE TABLE IF NOT EXISTS \`$ARCHIVE_DB\`.factures LIKE \`$PROD_DB\`.factures;

-- 3) Copier les clients inactifs et leurs factures dans l'archive
INSERT IGNORE INTO \`$ARCHIVE_DB\`.clients
    SELECT * FROM \`$PROD_DB\`.clients
     WHERE last_activity < $CUTOFF;

INSERT IGNORE INTO \`$ARCHIVE_DB\`.factures
    SELECT f.* FROM \`$PROD_DB\`.factures f
     JOIN \`$PROD_DB\`.clients c ON c.id = f.id_client
     WHERE c.last_activity < $CUTOFF;

-- 4) Anonymiser les données personnelles en production
UPDATE \`$PROD_DB\`.clients SET
    nom      = SHA2(nom,256),
    prenom   = SUBSTRING(SHA2(prenom,256),1,20),
    email    = CONCAT('anon+',id,'@example.local'),
    adresse  = NULL
 WHERE last_activity < $CUTOFF;

-- 5) (Optionnel) Marquer l'enregistrement comme anonymisé
-- ALTER TABLE \`$PROD_DB\`.clients ADD COLUMN anonymized TINYINT(1) DEFAULT 0;
-- UPDATE \`$PROD_DB\`.clients SET anonymized = 1 WHERE last_activity < $CUTOFF;
SQL

log "Fin du script : succès."

