# 🐳 Docker OpenClaw

> Déploiement complet d'OpenClaw Gateway avec Docker Compose, prêt à servir de cœur d'une plateforme.

![OpenClaw](https://img.shields.io/badge/OpenClaw-Gateway-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

# ✨ Fonctionnalités

- 🐳 Déploiement avec Docker Compose
- ⚙️ Configuration centralisée
- 🔌 Support des plugins personnalisés
- 💾 Persistance automatique des données
- 🌐 Compatible avec les canaux Web et WhatsApp
- 🤖 Gestion d'agents IA
- 🚀 Développement local simplifié
- 🏪 Prêt pour un Plateforme

---

# 🏗️ Architecture

```text
docker-openclaw
│
├── 📂 data/
├── 📂 plugins/
├── 📂 postman/
├── 📂 tests/
├── 📂 scripts/
├── 📂 docs/
├── 📄 docker-compose.yml
├── 📄 docker-compose.example.yml
├── 📄 .env
├── 📄 .env.example
└── 📄 README.md
```

---

# 📋 Prérequis

- 🐳 Docker Desktop
- 📦 Docker Compose
- 🌱 Git

Vérification :

```bash
docker --version
docker compose version
```

---

# 🚀 Installation

## 1️⃣ Cloner le projet

```bash
git clone <repository-url>

cd docker-openclaw
```

---

## 2️⃣ Copier les variables

```bash
cp .env.example .env
```

Puis modifier le fichier `.env`.

---

## 3️⃣ Démarrer OpenClaw

```bash
docker compose up -d
```

---

## 4️⃣ Vérifier les conteneurs

```bash
docker ps
```

---

## 5️⃣ Consulter les logs

```bash
docker compose logs -f
```

---

# ⏹️ Arrêter

```bash
docker compose down
```

---

# 🔄 Mise à jour

```bash
docker compose pull

docker compose up -d
```

---

# 📁 Structure du projet

## 📂 data/

Contient :

- 🤖 Agents
- ⚙️ Configurations
- 💾 Données
- 🔐 Sessions
- 📦 Cache

---

## 📂 plugins/

Extensions OpenClaw.

Exemple :

```text
plugins/
│
├── 📂 rest-api

```

---

# 🔧 Variables d'environnement

```env
OPENCLAW_PORT=18789

OPENCLAW_HOST=0.0.0.0

OPENCLAW_DATA=/home/node/.openclaw

OPENCLAW_PLUGINS=/home/node/.openclaw/plugins
```

---

# 💡 Cas d'utilisation

- 🤖 Assistant IA
- 💬 Chatbot WhatsApp
- 🌐 Chatbot Web
- 🛒 Gestion de catalogue
- 📦 Gestion de stock
- 🏪 SaaS multi-boutiques
- 📊 Support client

---

# 🏛️ Architecture

```text
                  🤖 OpenClaw Gateway
          ┌────────────┼────────────┐
          ▼            ▼            ▼
      💬 WhatsApp   🌐 Web     🔌 API Tools
```
---

# 🛠️ Développement

### 📄 Logs

```bash
docker compose logs -f
```

### 🔄 Redémarrer

```bash
docker compose restart
```

### 🏗️ Rebuild

```bash
docker compose up --build
```

---

# ✅ Bonnes pratiques

- ✅ Versionner uniquement les fichiers utiles
- 🔒 Ne jamais publier `.env`
- 💾 Sauvegarder le dossier `data`
- 🧩 Développer un plugin par dossier
- 🧪 Tester les plugins avant la production

---


# 🤝 Contribution

Les contributions sont les bienvenues.

1. 🍴 Fork
2. 🌿 Nouvelle branche
3. 💾 Commit
4. 🚀 Pull Request

---

# 📜 Licence

Distribué sous licence **MIT**.

---

# 👨‍💻 Auteur

**David Kasumbe**

🚀 Développé dans le cadre du projet **Sakem**, une plateforme SaaS basée sur OpenClaw permettant de déployer des agents IA spécialisés pour plusieurs boutiques.