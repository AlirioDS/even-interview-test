# 🚀 **QUICK START** - Rails API Boilerplate

## ⚡ **30 Segundos Setup**

```bash
cp .env.example .env
docker compose -f docker-compose.development.yml up --build
```

**¡Listo!** → http://localhost:3000

---

## 📦 **¿Qué incluye?**

- ✅ **Rails 8 API** - Última versión
- ✅ **PostgreSQL 17.5** - Base de datos optimizada  
- ✅ **Solid Queue** - Jobs en background
- ✅ **Docker** - Sin instalación local de Ruby/PostgreSQL

---

## 🔧 **Comandos Esenciales**

```bash
# 🚀 Iniciar
docker compose -f docker-compose.development.yml up -d

# 📊 Ver status  
docker compose ps

# 🗄️ Rails console
docker compose exec rails-api bin/rails console

# 📝 Ver logs
docker compose logs -f rails-api

# 🛑 Parar
docker compose down
```

---

## 🚨 **Troubleshooting**

**❌ Error de contraseña?**
```bash
docker compose down -v && docker compose up --build
```

**❌ Puerto ocupado?**
Cambiar `3000:3000` por `3001:3000` en docker-compose.development.yml

**❌ Todo roto?**
```bash
docker system prune -f && docker compose up --build
```

---

**📖 Documentación completa:** [README.md](README.md) | **⚡ Setup rápido:** [SETUP.md](SETUP.md) 
