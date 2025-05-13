#!/usr/bin/env bash
# ------------------------------------------------------------
# generate_report.sh – Rapport CA TTC (prod + archive)
# ------------------------------------------------------------
# Usage : ./generate_report.sh [FROM YYYY-MM-DD] [TO YYYY-MM-DD]
#   Si aucun argument n'est fournis, l'année courante est utilisée.
# Exemple : ./generate_report.sh 2024-01-01 2024-12-31 > rapport-2024.txt
# ------------------------------------------------------------
set -euo pipefail

# ----- Paramètres modifiables --------------------------------
PROD_DB="prod"
ARCHIVE_DB="archive"
MYSQL_USER="root"
# ------------------------------------------------------------

YEAR=$(date +%Y)
FROM="${1:-$YEAR-01-01}"
TO="${2:-$YEAR-12-31}"

# En-tête TSV
printf "mois\tca_ttc\n"

mysql --batch --silent --user="$MYSQL_USER" <<SQL
SELECT DATE_FORMAT(date,'%Y-%m')   AS mois,
       ROUND(SUM(montant_ttc),2)   AS ca_ttc
FROM (
    SELECT date, montant_ttc FROM \`$PROD_DB\`.factures    WHERE date BETWEEN '$FROM' AND '$TO'
    UNION ALL
    SELECT date, montant_ttc FROM \`$ARCHIVE_DB\`.factures WHERE date BETWEEN '$FROM' AND '$TO'
) AS union_factures
GROUP BY mois
ORDER BY mois;
SQL

