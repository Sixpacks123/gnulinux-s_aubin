# Guide d’installation détaillé – Exercice 2

> Ce guide pas‑à‑pas décrit la mise en place complète du **reverse‑proxy Caddy** devant l’application **Flask** ainsi que la protection **Fail2ban**.

---

## Sommaire

1. [Pré‑requis système](#pré--requis-système)
2. [Clonage du dépôt](#clonage-du-dépôt)
3. [Exécution du script `setup.sh`](#exécution-du-script-setupsh)
4. [Vérifications post‑installation](#vérifications-post--installation)
5. [Tests de sécurité Fail2ban](#tests-de-sécurité-fail2ban)
6. [Dépannage](#dépannage)
7. [Mises à jour & maintenance](#mises-à-jour--maintenance)

---

## 1. Pré‑requis système

| Élément  | Version testée         | Commentaires                                   |
| -------- | ---------------------- | ---------------------------------------------- |
| OS       | Debian 12 « Bookworm » | utilisateur `user` dans **sudo**               |
| Caddy    | v2.8                   | installé automatiquement                       |
| Python   | ≥ 3.11                 | paquet `python3` Debian                        |
| Fail2ban | v1.0                   | paquet Debian                                  |
| nftables | actif                  | Fail2ban utilise l’action `nftables-multiport` |


---

## 2. Clonage du dépôt

```bash
sudo apt update && sudo apt install -y git
# Placez‑vous où vous voulez stocker le code
cd /opt
cd gnulinux-adv-s_*/exo2
```


---

## 3. Exécution du script `setup.sh`

### 3.1. Version HTTPS (Let’s Encrypt)

Si vous disposez d’un **FQDN** pointant vers votre machine :

```bash
sudo ./scripts/setup.sh mon‑domaine.tld
```

Caddy obtiendra alors automatiquement un certificat TLS valide.

### 3.2. Version locale (HTTP)

Sans DNS, exécutez simplement :

```bash
sudo ./scripts/setup.sh
```

Le script utilisera le domaine par défaut **`example.test`** (pensez à ajouter `127.0.0.1 example.test` dans */etc/hosts* pour tester en navigateur).

---

## 4. Vérifications post‑installation

1. **Services systemd** :

   ```bash
   systemctl status flask-app caddy fail2ban
   ```
2. **Accès web** :

   ```bash
   curl -I https://mon‑domaine.tld/login   # HTTP 200 / 302 selon cas
   ```
3. **Log Caddy** :

   ```bash
   sudo tail -f /var/log/caddy/access.log
   ```

---

## 5. Tests de sécurité Fail2ban

1. **Simulation d’attaque brute‑force** :

   ```bash
   for i in {1..4}; do
     curl -s -o /dev/null -w "%{http_code}\n" \
       -d "user=alice&pw=wrong" https://mon‑domaine.tld/login;
   done
   ```
2. **Vérifier la jail** :

   ```bash
   sudo fail2ban-client status caddy-auth
   ```

   Vous devriez voir votre IP dans *Banned IP list*.
3. **Tester le blocage** :

   ```bash
   curl -I https://mon‑domaine.tld/login   # Réponse 403 ou timeout
   ```

---

## 6. Dépannage

| Problème                                        | Cause probable         | Solution                                           |
| ----------------------------------------------- | ---------------------- | -------------------------------------------------- |
| `systemctl status flask-app` -> Failed to start | Port 5000 déjà utilisé | Modifier `ExecStart` ou arrêter le service conflit |
| Caddy « error obtaining certificate »           | Port 80 bloqué/occupé  | Ouvrir/relâcher le port ou utiliser DNS challenge  |
| Fail2ban ne bannit pas                          | Regex non match        | Vérifier le code 302 en log & ajuster `failregex`  |

Logs utiles : `/var/log/caddy/access.log`, `/var/log/fail2ban.log`, `journalctl -u flask-app`.

---

## 7. Mises à jour & maintenance

* **Flask app** : pull Git + `systemctl restart flask-app`.
* **Caddy** & **Fail2ban** : via `apt upgrade` (versions stables).
* **Logs Caddy** : ajouter `/etc/logrotate.d/caddy` si volume important.

---

> 📝 **Note pédagogique** : ce guide met l’accent sur la reproductibilité sur une VM fraîche.
> Des hardenings supplémentaires (headers sécurité Caddy, secrets dans `systemd‑tmpfiles`) peuvent être ajoutés en production.

