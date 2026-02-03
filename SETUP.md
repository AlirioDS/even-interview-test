# ⚡ Setup Ultra-Rápido

**Para desarrolladores que quieren empezar YA** 🚀

## 🎯 **Setup en 3 Comandos**

```bash
# 1. Configurar variables de entorno
cp .env.example .env

# 2. Iniciar todo
docker compose -f docker-compose.development.yml up --build

# 3. Verificar que funciona
curl http://localhost:3000
```

**¡Listo!** En 2-3 minutos tienes todo corriendo.

---

## 🔧 **Personalización Opcional**

### **Cambiar contraseñas (opcional)**
```bash
# Las contraseñas ya están configuradas por defecto
# Si quieres cambiarlas, edita .env:
nano .env  # o code .env

# Asegúrate que estas tres variables tengan la misma contraseña:
DATABASE_PASSWORD=tu_password_unico
TEST_DATABASE_PASSWORD=tu_password_unico
POSTGRES_PASSWORD=tu_password_unico
```

### **Usar en background**
```bash
# Iniciar en segundo plano
docker compose -f docker-compose.development.yml up -d

# Ver logs cuando necesites
docker compose -f docker-compose.development.yml logs -f
```

---

## ✅ **Verificación Rápida**

### **Todo funciona si ves:**
```bash
# ✅ Status de containers
$ docker compose ps
NAME                                    COMMAND                  SERVICE             STATUS
rails_api_boiler_plate-db-postgres-1   "postgres..."            db-postgres         Up (healthy)
rails_api_boiler_plate-rails-api-1     "bash -lc 'bin/rails…"  rails-api           Up
rails_api_boiler_plate-queue-1         "bash -lc 'bin/rails…"  queue               Up

# ✅ API responde
$ curl http://localhost:3000
<!DOCTYPE html><html>...  # Página de bienvenida de Rails

# ✅ Base de datos conectada
$ docker compose exec rails-api bin/rails runner "puts ActiveRecord::Base.connection.active?"
true
```

---

## 🚨 **Si algo sale mal**

### **Error de contraseñas**
```bash
# Síntoma: "password authentication failed"
# Solución rápida:
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **Error de base de datos duplicada**
```bash
# Síntoma: "duplicate key value violates unique constraint"
# Causa: Los servicios intentan crear la BD al mismo tiempo
# Solución: Ya está arreglado automáticamente, pero si persiste:
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **Puertos ocupados**
```bash
# Síntoma: "port already in use"
# Cambiar puerto en docker-compose.development.yml:
ports:
  - "3001:3000"  # Cambiar 3000 por 3001
```

### **Empezar desde cero**
```bash
# Borrar todo y empezar limpio
docker compose -f docker-compose.development.yml down -v
docker system prune -f
docker compose -f docker-compose.development.yml up --build
```

---

## 🎯 **Primeros Pasos Después del Setup**

### **Explorar la API**
```bash
# Abrir en el navegador
open http://localhost:3000

# O con curl
curl http://localhost:3000
```

### **Rails Console**
```bash
# Entrar a la consola de Rails
docker compose exec rails-api bin/rails console

# Dentro de la consola:
> Rails.env
=> "development"
> ActiveRecord::Base.connection.active?
=> true
```

### **Ver logs en tiempo real**
```bash
# Logs de todos los servicios
docker compose -f docker-compose.development.yml logs -f

# Solo logs de Rails API
docker compose -f docker-compose.development.yml logs -f rails-api

# Solo logs de la queue
docker compose -f docker-compose.development.yml logs -f queue
```

### **Crear tu primer modelo**
```bash
# Generar un modelo de ejemplo
docker compose exec rails-api bin/rails generate model User name:string email:string

# Ejecutar migración
docker compose exec rails-api bin/rails db:migrate

# Probar en consola
docker compose exec rails-api bin/rails console
> User.create(name: "Test", email: "test@example.com")
> User.all
```

---

## 🎁 **Comandos Útiles**

```bash
# Aliases para ahorrar tiempo (agregar a .bashrc/.zshrc)
alias dc="docker compose -f docker-compose.development.yml"
alias rails-exec="docker compose exec rails-api"
alias rails-console="docker compose exec rails-api bin/rails console"

# Uso:
dc up -d
rails-exec bin/rails db:migrate
rails-console
```

---

**🎉 ¡Ya tienes tu Rails API funcionando! Ahora ve al [README.md](README.md) para más detalles.** 
