# 🔐 Estrategia Híbrida de Credenciales

## 🎯 **Filosofía: .env para Dev/Test, Credentials para Producción**

### **🏠 Development/Tests → .env files**
- Variables de entorno simples
- Fácil configuración por desarrollador
- Sin necesidad de compartir secrets

### **🏭 Production → Rails Credentials**
- Cifrado y versionado
- API keys de terceros
- Secrets críticos

## 📋 **Configuración para Development/Tests**

### 1. **Configurar Variables de Entorno**

Edita el archivo `.env` con tus credenciales:

```bash
# Editar credenciales
nano .env

# O usar tu editor preferido
code .env
```

**Variables importantes a configurar:**

```env
# Cambia estas contraseñas por unas más seguras
DATABASE_PASSWORD=tu_password_seguro_aqui
TEST_DATABASE_PASSWORD=tu_test_password_aqui  
POSTGRES_PASSWORD=tu_admin_password_aqui
# NO necesitas RAILS_MASTER_KEY para development/tests
```

### 2. **Rails Credentials (Solo para Producción)**

Las credenciales están configuradas solo con ejemplos comentados:

```bash
# Ver credenciales actuales
bin/rails credentials:show

# Solo contiene secret_key_base y ejemplos comentados para producción
```

## 🏗️ **Configuración Simplificada de BD**

### **👤 Usuario Único para Simplicidad:**

- **`postgres`** - Usuario único para development y tests (máxima simplicidad)

### **🔒 Principios de la Estrategia Híbrida:**

- ✅ **Separación por entorno**: .env para dev/test, credentials para prod
- ✅ **Máxima simplicidad**: Un solo usuario postgres para dev/test
- ✅ **Sin compartir secretos**: Cada dev maneja sus .env
- ✅ **Gitignore**: `.env` nunca se sube al repo
- ✅ **Producción segura**: Credentials cifradas para secrets críticos

## 🚀 **Uso**

### **Iniciar Servicios:**

```bash
# Primera vez (creará usuarios automáticamente)
docker compose -f docker-compose.development.yml up --build

# Ejecutar en segundo plano
docker compose -f docker-compose.development.yml up -d
```

### **Verificar Conexión:**

```bash
# Conectar a la base de datos de desarrollo
docker compose exec db-postgres psql -U postgres -d bd_template_dev

# Conectar a la base de datos de test
docker compose exec db-postgres psql -U postgres -d rails_api_test
```

### **Ejecutar Tests:**

```bash
# Tests usarán automáticamente el usuario postgres
docker compose exec rails-api bin/rails test
```

## 🔧 **Troubleshooting**

### **Error de Conexión:**

```bash
# Recrear la base de datos
docker compose -f docker-compose.development.yml down -v
docker compose -f docker-compose.development.yml up --build
```

### **Cambiar Contraseñas:**

1. Actualiza `.env` 
2. Reconstruye containers:
   ```bash
   docker compose down -v
   docker compose up --build
   ```

## 📚 **Archivos Importantes**

- **`.env`** - Variables de entorno (NO subir a git)
- **`.env.example`** - Template de variables
- **`config/database.yml`** - Configuración de Rails
- **`docker-compose.development.yml`** - Orquestación de servicios

## 🛡️ **Buenas Prácticas por Entorno**

### **Development/Tests (.env):**
1. **Nunca subas `.env` al repositorio**
2. **Usa contraseñas simples pero únicas**
3. **Mantén `env.example` actualizado**
4. **No uses RAILS_MASTER_KEY en development**

### **Production (Rails Credentials):**
1. **Usa contraseñas fuertes y complejas**
2. **Mantén config/master.key segura**
3. **Rota credenciales regularmente**
4. **Audita acceso a credenciales**

## 📊 **Comparación**

| Aspecto | .env (Dev/Test) | Credentials (Prod) |
|---------|----------------|-------------------|
| **🔒 Seguridad** | Básica (OK para dev) | Alta (cifrado) |
| **👥 Setup** | `cp env.example .env` | Requiere master.key |
| **🔄 Cambios** | Inmediatos | Requiere deployment |
| **🐛 Debug** | Valores visibles | Valores ocultos |
| **📝 Versionado** | No (gitignore) | Sí (cifrado) |

---

*🎯 **Resultado**: Simplicidad en desarrollo, seguridad en producción.* 
