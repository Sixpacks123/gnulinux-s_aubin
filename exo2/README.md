# Exercice 2 – Reverse Proxy Caddy + Fail2ban (20 pts)

Ce dossier démontre la mise en place d’un **serveur web dynamique** protégé par :

* **Caddy** (reverse‑proxy HTTPS automatique) ;
* **Fail2ban** (bannissement IP après tentatives de login).

L’application test est un mini‑service **Flask** exposant :

* `GET /login` : formulaire d’authentification ;
* `POST /login` : vérifie les *credentials* codés en dur ;
* `GET /private` : contenu privé accessible seulement une fois connecté.

---

## 1. Arborescence du dossier

```
exercice2/
├── app/
│   └── main.py            # application Flask (WSGI)
├── Caddyfile              # configuration du reverse‑proxy
├── fail2ban/
│   ├── caddy-auth.conf    # filtre custom
│   └── caddy-auth.local   # jail
├── scripts/
│   └── setup.sh           # installe dépendances + service systemd + fail2ban
└── docs/
    └── guide-installation.md
```

---

## 2. Prérequis

* Debian 12 « Bookworm »
* utilisateur `user` membre de **sudo**
* **Python 3.11**, `pip`, `virtualenv`
* **nftables** déjà actif (fail2ban utilisera l’action `nftables-multiport`)


---

## 3. Installation rapide

```bash
git clone https://github.com/<mon-login>/gnulinux-adv-s_paul.git
cd gnulinux-adv-s_paul/exercice2
sudo ./scripts/setup.sh            # tout installe et démarre
```

Au terme du script :

* Caddy écoute sur **80/443** (auto‑HTTPS) et proxy sur `localhost:5000` ;
* l’appli Flask tourne via **systemd** (`service flask-app`) ;
* la jail **fail2ban** `caddy-auth` est active.

---

## 4. Test rapide

```bash
curl -i https://example.test/login        # page login (302 ➜ formulaire)
curl -d "user=alice&pw=wrong" https://example.test/login  # 302 à chaque échec
# ➜ après 3 échecs en <10 min, votre IP sera bannie 12 h
```

Vérifier l’état :

```bash
sudo fail2ban-client status caddy-auth
```

---

## 5. Références

* Caddy Docs : *Reverse Proxy Quick‑Start*
* Fail2ban Docs : *Writing Custom Filters*
* Flask : *Quickstart* (minimal app)

---

