# 📁 Estructura del Proyecto

**Guía completa de archivos y directorios**

## 🎯 **Archivos Principales**

### **📚 Documentación**
```
📖 README.md                 # Documentación principal completa  
⚡ QUICK_START.md            # Setup en 30 segundos
🚀 SETUP.md                  # Setup ultra-rápido con explicaciones
🔐 README_CREDENTIALS.md     # Gestión detallada de credenciales
📁 PROJECT_STRUCTURE.md      # Este archivo (estructura del proyecto)
```

### **🐳 Docker & Configuración**
```
🐳 docker-compose.development.yml  # Orquestación de servicios para desarrollo
🔧 Dockerfile.development          # Imagen de Rails para desarrollo
🌍 .env                           # Variables de entorno (NO subir a git)
📝 .env.example                   # Template de variables de entorno
🚫 .gitignore                     # Archivos ignorados por Git
```

### **🗄️ Configuración Rails**
```
config/
├── 🗃️ database.yml              # Configuración BD híbrida (.env + credentials)
├── 🔐 credentials/              # Credenciales cifradas (solo ejemplos prod)
│   ├── development.yml.enc      # Ejemplos comentados para producción
│   └── development.key          # Clave de cifrado
├── ⚡ queue.yml                 # Configuración Solid Queue
├── 📅 recurring.yml             # Tareas programadas
├── 💾 cache.yml                 # Configuración Solid Cache  
├── 📡 cable.yml                 # Configuración Solid Cable
├── 🚀 deploy.yml                # Configuración Kamal (deployment)
└── environments/                # Configuraciones por entorno
    ├── development.rb           # Configuración desarrollo
    ├── test.rb                  # Configuración tests
    └── production.rb            # Configuración producción
```

### **🗄️ Base de Datos**
```
db/
├── 📊 schema.rb                 # Schema principal de Rails (vacío inicial)
├── ⚡ queue_schema.rb           # Schema de Solid Queue (tablas de jobs)
├── 💾 cache_schema.rb           # Schema de Solid Cache
├── 📡 cable_schema.rb           # Schema de Solid Cable
└── migrate/                     # Migraciones (se crean al hacer generators)
```

### **📜 Scripts**
```
script/
└── .keep                       # Directorio vacío (simplificado)
                                # Antes tenía scripts complejos, ahora todo está 
                                # integrado directamente en docker-compose
```

### **⚙️ Rails Estándar**
```
📦 Gemfile                      # Dependencias Ruby
🔒 Gemfile.lock                 # Versiones exactas de dependencias
🏗️ config.ru                   # Configuración Rack
📱 app/                         # Código de la aplicación
   ├── controllers/             # Controladores
   ├── models/                  # Modelos
   ├── jobs/                    # Jobs de background
   └── ...
🧪 test/                        # Tests
📁 bin/                         # Scripts ejecutables de Rails
   ├── rails                    # CLI de Rails
   ├── jobs                     # Script para Solid Queue
   └── ...
```

---

## 🎛️ **Flujo de Funcionamiento**

### **🚀 Al ejecutar `docker compose up`:**

1. **🐘 db-postgres** se inicia con:
   - Variables de `.env` (POSTGRES_USER, POSTGRES_PASSWORD)
   - Optimizaciones automáticas de PostgreSQL
   - Healthcheck cada 10s

2. **🚀 rails-api** espera a que DB esté "healthy" y ejecuta:
   ```bash
   bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000
   ```

3. **⚡ queue** espera a que rails-api esté "started" y ejecuta:
   ```bash
   bin/rails db:prepare && bin/rails runner "load 'db/queue_schema.rb'" && bin/rails solid_queue:start
   ```

### **🔄 Variables de Entorno:**
```
.env → docker-compose.development.yml → containers → Rails config/database.yml
```

---

## 🧠 **Decisiones de Diseño**

### **✅ Lo que Simplificamos:**
- **Scripts complejos** → Comandos directos en docker-compose
- **Múltiples usuarios BD** → Usuario único `postgres`
- **Múltiples contraseñas** → Una sola contraseña para dev/test
- **Archivos de credenciales por entorno** → Solo ejemplos para producción

### **✅ Lo que Mantuvimos:**
- **Solid Stack completo** - Queue, Cache, Cable (Rails 8)
- **Estrategia híbrida** - .env para dev, credentials para prod
- **Configuraciones optimizadas** - PostgreSQL tuneado
- **Escalabilidad** - Queue workers escalables

### **✅ Lo que Agregamos:**
- **Documentación completa** - 5 archivos de docs especializados
- **Setup automatizado** - Scripts de una línea
- **Troubleshooting** - Soluciones a problemas comunes
- **Healthchecks robustos** - Verificación automática de servicios

---

## 🎯 **Casos de Uso por Archivo**

### **🏃‍♂️ Quiero empezar rápido:**
→ `QUICK_START.md` (30 segundos)

### **🧑‍💻 Soy desarrollador nuevo:**
→ `SETUP.md` (setup completo explicado)

### **📚 Necesito documentación completa:**
→ `README.md` (guía completa)

### **🔐 Problemas con credenciales:**
→ `README_CREDENTIALS.md` (estrategia híbrida detallada)

### **🗂️ ¿Qué hace cada archivo?:**
→ `PROJECT_STRUCTURE.md` (este archivo)

### **⚙️ Configurar servicios:**
→ `docker-compose.development.yml` (orquestación)

### **🔧 Variables de entorno:**
→ `.env.example` (template) → `.env` (tu configuración)

---

## 🎉 **Resultado Final**

**Un proyecto Rails 8 API con:**
- ✅ **Setup en minutos** - Sin instalaciones locales
- ✅ **Máxima simplicidad** - Sin over-engineering
- ✅ **Fully featured** - Todo lo necesario para APIs modernas
- ✅ **Bien documentado** - Para cualquier nivel de experiencia
- ✅ **Production ready** - Con path claro a producción

**¡Perfect balance entre simplicidad y funcionalidad!** 🎯 
