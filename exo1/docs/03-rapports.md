# 03 – Génération des rapports de CA TTC

Ce document décrit l’usage du script `generate_report.sh` et la structure des rapports produits.

---

## 1. Fonctionnement

Le script interroge **deux schémas** (`prod` + `archive`) puis agrège le **CA TTC par mois** entre deux dates.

### 1.1. Exécution automatique

Planifiée chaque **22 décembre à 04 h** :

* Dépôt dans `/srv/reports/rapport-AAAA.txt`
* Format tabulé (facilement importable) :

```
mois    ca_ttc
2025-01 7021.05
2025-02 6310.44
...
```

### 1.2. Exécution manuelle (audit ponctuel)

```bash
# Exemple : CA 2023
./scripts/generate_report.sh 2023-01-01 2023-12-31 > /tmp/rapport-2023.txt
```

Paramètres :

| Position | Signification           | Valeur par défaut          |
| -------- | ----------------------- | -------------------------- |
| `$1`     | Date début (YYYY-MM-DD) | 1ᵉʳ janvier année courante |
| `$2`     | Date fin (YYYY-MM-DD)   | 31 décembre année courante |

---

## 2. Import dans LibreOffice Calc / Excel

1. **Fichier > Ouvrir** le `.txt`
2. Choisir le séparateur **Tabulation**
3. Définir la colonne *ca\_ttc* au format **Nombre** (*2 décimales*).

Pour un reporting plus évolué, le fichier peut être chargé dans un outil BI (Metabase, Grafana, etc.).

---

## 3. Maintenance & nettoyage

* Les rapports anciens peuvent être archivés ou supprimés au bout de X années selon votre politique documentaire.
* Pour désactiver le reporting, commenter ou supprimer la ligne correspondante dans `/etc/cron.d/rgpd`.

---

## 4. Références RGPD / CNIL

* Règlement UE 2016/679 – Articles 5 et 32.
* CNIL – *Guide RGPD développeur* (2023).
* CNIL – *Durées de conservation des données* (maj 2024).

---

Retour au [README principal](../../README.md) ou passez à l’[exercice 2](../exercice2/README.md).

