# 🚀 Rails API Boilerplate

Rails 8 API con **PostgreSQL**, **Solid Queue**, **Solid Cache** y **Solid Cable** usando Docker para desarrollo.

> **🏃‍♂️ ¿Quieres empezar YA?** → [QUICK_START.md](QUICK_START.md) (30 segundos)  
> **📁 ¿Qué hace cada archivo?** → [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)  
> **🔐 ¿Problemas con credenciales?** → [README_CREDENTIALS.md](README_CREDENTIALS.md)

## 📋 **Inicio Rápido (5 minutos)**

### 1. **Clonar y Configurar**
```bash
git clone <repository>
cd rails_api_boiler_plate

# Configurar variables de entorno
cp .env.example .env
```

### 2. **Verificar Credenciales (Opcional)**
Las contraseñas ya están configuradas. Si quieres cambiarlas, edita `.env`:
```bash
# Opcional: Cambiar contraseñas (deben coincidir)
DATABASE_PASSWORD=tu_password_aqui
TEST_DATABASE_PASSWORD=tu_password_aqui
POSTGRES_PASSWORD=tu_password_aqui
```

### 3. **Iniciar Servicios**
```bash
docker compose -f docker-compose.development.yml up --build
```

**¡Listo!** Tu API estará en http://localhost:3000

---

## 🏗️ **Arquitectura del Sistema**

### **🐘 Base de Datos**
- **PostgreSQL 17.5** con optimizaciones para desarrollo
- **Usuario único**: `postgres` (máxima simplicidad)
- **Bases separadas**: `bd_template_dev` (dev) y `rails_api_test` (tests)

### **⚡ Background Jobs** 
- **Solid Queue** - Procesamiento de trabajos en background
- **Worker escalable**: `docker compose up --scale queue=3`

### **🔐 Estrategia de Credenciales Híbrida**
- **Development/Tests**: Variables de entorno (`.env`)
- **Production**: Rails credentials cifradas

---

## 📁 **Estructura del Proyecto**

```
rails_api_boiler_plate/
├── 🐳 docker-compose.development.yml  # Orquestación de servicios
├── 🔐 .env                           # Variables de entorno (NO subir a git)
├── 📝 .env.example                   # Template de variables
├── 🗄️ config/
│   ├── database.yml                  # Configuración de BD híbrida
│   ├── credentials/                  # Solo ejemplos para producción
│   ├── queue.yml                     # Configuración Solid Queue
│   └── recurring.yml                 # Tareas programadas
├── 📜 script/                        # Solo .keep (simplificado)
└── 📚 README_CREDENTIALS.md          # Documentación detallada
```

---

## 🚀 **Comandos Principales**

### **Desarrollo**
```bash
# Iniciar servicios
docker compose -f docker-compose.development.yml up

# En segundo plano
docker compose -f docker-compose.development.yml up -d

# Ver logs
docker compose -f docker-compose.development.yml logs -f

# Parar servicios
docker compose -f docker-compose.development.yml down
```

### **Base de Datos**
```bash
# Conectar a la BD de desarrollo
docker compose exec db-postgres psql -U postgres -d bd_template_dev

# Resetear BD (elimina datos)
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **Rails Console**
```bash
# Console de Rails
docker compose exec rails-api bin/rails console

# Ejecutar comando Rails
docker compose exec rails-api bin/rails db:migrate
```

### **Tests**
```bash
# Ejecutar tests
docker compose exec rails-api bin/rails test

# Tests con cobertura
docker compose exec rails-api bin/rails test:system
```

### **Queue Workers**
```bash
# Ver trabajos en cola
docker compose exec rails-api bin/rails runner "puts SolidQueue::Job.count"

# Escalar workers
docker compose up --scale queue=3 -d
```

---

## 🔧 **Configuración Avanzada**

### **Variables de Entorno Importantes**

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DATABASE_PASSWORD` | Contraseña de Rails → PostgreSQL | `postgres_dev_2024` |
| `POSTGRES_PASSWORD` | Contraseña del container PostgreSQL | **Debe coincidir con DATABASE_PASSWORD** |
| `JOB_CONCURRENCY` | Workers de Solid Queue | `2` |
| `RAILS_MAX_THREADS` | Threads de Puma | `5` |
| `RAILS_LOG_LEVEL` | Nivel de logging | `info` |

### **Optimizaciones de PostgreSQL**
El container incluye optimizaciones automáticas:
- `shared_buffers=128MB` - Memoria compartida
- `effective_cache_size=512MB` - Cache estimado
- `synchronous_commit=off` - Mejor rendimiento para jobs
- `autovacuum_naptime=20s` - Limpieza frecuente

---

## 🐛 **Troubleshooting**

### **❌ Error: "password authentication failed"**
**Problema**: Las contraseñas en `.env` no coinciden.

**Solución**:
```bash
# 1. Verificar que coincidan en .env:
DATABASE_PASSWORD=tu_password
POSTGRES_PASSWORD=tu_password  # ⚠️ Deben ser iguales

# 2. Recrear containers:
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **❌ Error: "relation solid_queue_processes does not exist"**
**Problema**: Tablas de Solid Queue no están creadas.

**Solución**: Ya está solucionado automáticamente en el docker-compose, pero si necesitas hacerlo manual:
```bash
docker compose exec rails-api bin/rails runner "load 'db/queue_schema.rb'"
```

### **❌ Error: "duplicate key value violates unique constraint"**
**Problema**: Race condition - ambos servicios intentan crear la BD al mismo tiempo.

**Solución**: Ya está solucionado automáticamente. Si persiste:
```bash
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **❌ Los containers no arrancan**
**Problema**: Conflictos de puertos o volúmenes.

**Solución**:
```bash
# Limpiar todo y empezar desde cero
docker compose -f docker-compose.development.yml down -v
docker system prune -f
docker compose -f docker-compose.development.yml up --build
```

### **❌ Cambios en Gemfile no se reflejan**
**Problema**: La imagen no se reconstruyó.

**Solución**:
```bash
docker compose -f docker-compose.development.yml build --no-cache
docker compose -f docker-compose.development.yml up
```

---

## 🔐 **Gestión de Credenciales**

### **Para Development/Tests (Actual)**
Usa `.env` files para máxima simplicidad:

```bash
# Editar credenciales locales
nano .env

# Cada developer tiene sus propias credenciales
# No se suben al repositorio (.gitignore)
```

### **Para Producción (Futuro)**
Cuando deploys a producción, usa Rails credentials:

```bash
# Editar credenciales de producción
bin/rails credentials:edit

# Descomenta ejemplos en config/database.yml
# y config/credentials.yml.enc
```

Más detalles en: [README_CREDENTIALS.md](README_CREDENTIALS.md)

---

## 📊 **Servicios y Puertos**

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **rails-api** | 3000 | API principal de Rails |
| **db-postgres** | 5432 | Base de datos PostgreSQL |
| **queue** | - | Workers de Solid Queue (sin puerto) |

---

## 🚦 **Estados de Salud**

### **Verificar que todo funciona**:
```bash
# 1. Servicios activos
docker compose ps

# 2. API respondiendo
curl http://localhost:3000

# 3. Base de datos conectada
docker compose exec rails-api bin/rails runner "puts ActiveRecord::Base.connection.active?"

# 4. Solid Queue funcionando
docker compose exec rails-api bin/rails runner "puts SolidQueue::Process.count"
```

### **Indicadores de salud**:
- ✅ `rails-api` - Status "Up" y responde en puerto 3000
- ✅ `db-postgres` - Status "Up (healthy)"  
- ✅ `queue` - Status "Up" y logs sin errores

---

## 🎯 **Próximos Pasos**

### **Desarrollo**
1. Crear tus modelos: `docker compose exec rails-api bin/rails generate model User`
2. Crear controladores: `docker compose exec rails-api bin/rails generate controller api/v1/users`
3. Agregar jobs: `docker compose exec rails-api bin/rails generate job SendEmail`

### **Testing**
1. Configurar RSpec (opcional): Agregar `rspec-rails` al Gemfile
2. Configurar factory_bot: Para fixtures de test
3. Configurar simplecov: Para coverage de código

### **Deployment**
1. Configurar credentials de producción
2. Setup de CI/CD (GitHub Actions incluido)
3. Deploy con Kamal (configuración incluida)

---

## 📚 **Documentación Adicional**

- [README_CREDENTIALS.md](README_CREDENTIALS.md) - Gestión detallada de credenciales
- [Solid Queue Docs](https://github.com/rails/solid_queue) - Documentación oficial
- [Rails 8 Guide](https://guides.rubyonrails.org/) - Guías de Rails

---

## 💡 **Tips de Productividad**

### **Aliases útiles**:
```bash
# Agregar a tu .bashrc/.zshrc
alias dc="docker compose -f docker-compose.development.yml"
alias rails-exec="docker compose exec rails-api"
alias rails-logs="docker compose logs -f rails-api"

# Uso:
dc up -d
rails-exec bin/rails console
rails-logs
```

### **VS Code Setup**:
- Instalar extensión "Dev Containers"
- Usar "Remote - Containers" para desarrollo dentro del container
- Configurar debugger para Ruby

---

## 🤝 **Contribuir**

1. Fork el proyecto
2. Crea una feature branch: `git checkout -b feature/nueva-feature`
3. Commit tus cambios: `git commit -m 'Agregar nueva feature'`
4. Push a la branch: `git push origin feature/nueva-feature`
5. Abre un Pull Request

---

**¡Happy coding! 🎉**
