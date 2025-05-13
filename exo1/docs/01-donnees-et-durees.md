# 01 – Données personnelles & durées de conservation

> **Contexte** : identifier les champs sensibles de la base *prod* et définir la politique de conservation/conformité RGPD.

## 1. Cartographie des données

| Table      | Champ                                | Catégorie CNIL       | Sensible ?              | Commentaire                     |
| ---------- | ------------------------------------ | -------------------- | ----------------------- | ------------------------------- |
| `clients`  | `id`                                 | Identifiant interne  | Non                     | Clé primaire technique          |
|            | `nom`, `prenom`                      | Identification       | **Oui**                 | Données directement nominatives |
|            | `email`                              | Contact              | **Oui**                 | Courriel personnel/pro          |
|            | `adresse`                            | Localisation postale | **Oui**                 | Donnée à caractère personnel    |
|            | `mot_de_passe` (hash)                | Authentification     | Donnée particulière     | Stockage haché + salt           |
| `factures` | `id_client`                          | Identifiant          | **Oui** (clé étrangère) | Lien vers client                |
|            | `date`, `montant_ttc`, `num_facture` | Donnée commerciale   | Non (obligation légale) | Documents comptables            |

## 2. Durées de conservation appliquées

| Catégorie                          | Base légale                         | Conservation active                        | Archivage intermédiaire         | Suppression / anonymisation |
| ---------------------------------- | ----------------------------------- | ------------------------------------------ | ------------------------------- | --------------------------- |
| Données client (identité, contact) | Contrat + intérêt légitime          | Vie du compte + **3 ans** après inactivité | **2 ans** supplémentaires       | Anonymisation irréversible  |
| Mots de passe (hash)               | Sécurité (art. 32)                  | **12 mois** (historique réinit.)           | —                               | Suppression                 |
| Factures                           | Obligation légale (C. Com. L123‑22) | **10 ans**                                 | Conservation sans anonymisation | —                           |

> **Justification** : le RGPD (art. 5‑1‑e) impose de « ne pas conserver les données plus longtemps que nécessaire ».
> Les durées ci‑dessus suivent la *Référence CNIL – durées de conservation* (mise à jour 2024).

---

**Prochaine étape :** [02 – Processus automatisé](./02-processus-rgpd.md)

