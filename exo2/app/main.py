"""
Minimal Flask app for Exercice 2 – GNU/Linux avancé
---------------------------------------------------
Endpoints:
    • GET /login           – displays login form
    • POST /login          – credential check (hard‑coded) → redirects
    • GET /private         – protected resource (session‑based)

Run with: `python3 -m flask --app main run -h 127.0.0.1 -p 5000`
(Production: the setup script deploys a systemd service + Caddy reverse proxy.)
"""
from flask import Flask, request, redirect, session, render_template_string

app = Flask(__name__)
app.secret_key = "change‑me‑please"  # overriden at deploy time

# Hard‑coded credentials (subject spec)
CREDS = {"alice": "passw0rd!", "bob": "hunter2"}

login_tpl = """
<!doctype html>
<title>Login</title>
<h1>Authentification</h1>
<form method="post">
  <input name="user" placeholder="Utilisateur" required><br>
  <input name="pw" type="password" placeholder="Mot de passe" required><br>
  <button>Se connecter</button>
</form>
{% if msg %}<p style="color:red">{{ msg }}</p>{% endif %}
"""


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form.get("user", "")
        pw = request.form.get("pw", "")
        if CREDS.get(user) == pw:
            session["user"] = user
            return redirect("/private")
        # Failed auth → log + redirect (302) for Fail2ban filter
        app.logger.warning("AUTH FAIL user=%s ip=%s", user, request.remote_addr)
        return redirect("/login", code=302)
    return render_template_string(login_tpl, msg="")


@app.route("/private")
def private():
    if "user" not in session:
        return redirect("/login")
    return f"Accès au contenu privé autorisé – Bienvenue {session['user']}!"


# Healthcheck endpoint (optionnel)
@app.get("/ping")
def ping():
    return "pong", 200


if __name__ == "__main__":
    # Dev server only – in production, use systemd + gunicorn/uwsgi
    app.run(host="127.0.0.1", port=5000, debug=False)

