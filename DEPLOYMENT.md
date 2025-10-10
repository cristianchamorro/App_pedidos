# 🚀 Guía de Despliegue - App Pedidos

Esta guía cubre el despliegue de la aplicación en diferentes entornos.

---

## 📋 Tabla de Contenidos

1. [Despliegue Local](#despliegue-local)
2. [Despliegue en Servidor (VPS)](#despliegue-en-servidor-vps)
3. [Despliegue de Backend con PM2](#despliegue-de-backend-con-pm2)
4. [Despliegue Frontend Web](#despliegue-frontend-web)
5. [Despliegue Móvil (APK/IPA)](#despliegue-móvil-apkipa)
6. [Variables de Entorno](#variables-de-entorno)
7. [Consideraciones de Seguridad](#consideraciones-de-seguridad)

---

## 💻 Despliegue Local

### Desarrollo

Ver [SETUP.md](SETUP.md) para configuración completa de desarrollo local.

**Resumen rápido:**
```bash
# Terminal 1: Backend
cd app_backend
npm install
npm start

# Terminal 2: Frontend
cd app_frontend
flutter pub get
flutter run -d chrome
```

---

## 🌐 Despliegue en Servidor (VPS)

### Requisitos del Servidor

- Ubuntu 20.04+ / Debian 10+
- 2GB RAM mínimo
- 20GB almacenamiento
- Node.js 14+
- PostgreSQL 12+
- Nginx (opcional, para reverse proxy)

### 1. Configurar el Servidor

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Instalar PostgreSQL y PostGIS
sudo apt install -y postgresql postgresql-contrib postgis

# Instalar Nginx
sudo apt install -y nginx
```

### 2. Configurar PostgreSQL

```bash
# Crear usuario y base de datos
sudo -u postgres psql

CREATE USER app_pedidos WITH PASSWORD 'tu_contraseña_segura';
CREATE DATABASE "Bd_App" OWNER app_pedidos;
GRANT ALL PRIVILEGES ON DATABASE "Bd_App" TO app_pedidos;
\c Bd_App
CREATE EXTENSION postgis;
\q
```

### 3. Desplegar Backend

```bash
# Clonar repositorio
cd /var/www
sudo git clone https://github.com/cristianchamorro/App_pedidos.git
sudo chown -R $USER:$USER App_pedidos
cd App_pedidos/app_backend

# Instalar dependencias
npm install --production

# Crear archivo .env
cat > .env << 'ENVFILE'
DB_USER=app_pedidos
DB_HOST=localhost
DB_NAME=Bd_App
DB_PASSWORD=tu_contraseña_segura
DB_PORT=5432
PORT=3000
NODE_ENV=production
ENVFILE

# Cargar esquema de base de datos
PGPASSWORD=tu_contraseña_segura psql -U app_pedidos -d Bd_App -f esquema.sql

# Iniciar con PM2 (ver siguiente sección)
```

### 4. Configurar Nginx como Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/app_pedidos
```

Contenido:
```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Activar configuración:
```bash
sudo ln -s /etc/nginx/sites-available/app_pedidos /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. SSL con Let's Encrypt (Opcional pero Recomendado)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d tu-dominio.com
```

---

## 🔄 Despliegue de Backend con PM2

PM2 mantiene tu aplicación corriendo en segundo plano y la reinicia automáticamente si falla.

### Instalar PM2

```bash
sudo npm install -g pm2
```

### Iniciar Aplicación

```bash
cd /var/www/App_pedidos/app_backend
pm2 start server.js --name app_pedidos
pm2 save
pm2 startup
```

### Comandos Útiles de PM2

```bash
# Ver status
pm2 status

# Ver logs
pm2 logs app_pedidos

# Reiniciar
pm2 restart app_pedidos

# Detener
pm2 stop app_pedidos

# Eliminar
pm2 delete app_pedidos

# Ver monitoreo
pm2 monit
```

---

## 🌐 Despliegue Frontend Web

### Opción 1: Firebase Hosting

```bash
cd app_frontend

# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto
firebase init hosting

# Build para web
flutter build web

# Desplegar
firebase deploy
```

### Opción 2: Netlify

```bash
cd app_frontend

# Build
flutter build web

# Subir carpeta build/web a Netlify
# O conectar repositorio GitHub directamente
```

### Opción 3: Servidor con Nginx

```bash
cd app_frontend
flutter build web

# Copiar archivos al servidor
scp -r build/web/* user@servidor:/var/www/app_pedidos_web/
```

Configuración Nginx:
```nginx
server {
    listen 80;
    server_name app.tu-dominio.com;
    
    root /var/www/app_pedidos_web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 📱 Despliegue Móvil (APK/IPA)

### Android (APK)

```bash
cd app_frontend

# Build APK de release
flutter build apk --release

# El APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

Para Google Play Store:
```bash
# Build App Bundle
flutter build appbundle --release

# El archivo estará en: build/app/outputs/bundle/release/app-release.aab
```

### iOS (IPA)

Requiere macOS y cuenta de Apple Developer.

```bash
cd app_frontend

# Build IPA
flutter build ios --release

# Después usar Xcode para archivar y subir a App Store
```

---

## 🔐 Variables de Entorno

### Backend (.env)

```bash
# Base de Datos
DB_USER=postgres
DB_HOST=localhost
DB_NAME=Bd_App
DB_PASSWORD=tu_contraseña_segura
DB_PORT=5432

# Servidor
PORT=3000
NODE_ENV=production

# CORS
CORS_ORIGIN=https://tu-dominio.com

# Opcional: JWT para autenticación
JWT_SECRET=tu_secreto_jwt_muy_largo_y_seguro
```

### Frontend (api_service.dart)

Para producción, actualizar la URL base:

```dart
class ApiService {
  final String baseUrl = 'https://api.tu-dominio.com';
  // o usar flutter_dotenv para configuración por entorno
```

---

## 🔒 Consideraciones de Seguridad

### 1. Base de Datos

- ✅ Usar contraseñas seguras (mínimo 16 caracteres)
- ✅ No usar usuario `postgres` en producción
- ✅ Limitar conexiones solo desde localhost
- ✅ Hacer backups regulares

```bash
# Backup
pg_dump -U app_pedidos Bd_App > backup_$(date +%Y%m%d).sql

# Restore
psql -U app_pedidos Bd_App < backup_20251010.sql
```

### 2. Backend

- ✅ Nunca commitear archivo .env
- ✅ Usar HTTPS en producción
- ✅ Implementar rate limiting
- ✅ Validar y sanitizar todas las entradas
- ✅ Usar JWT o sessions para autenticación
- ✅ Hash de contraseñas con bcrypt

Ejemplo de hash de contraseñas:
```javascript
const bcrypt = require('bcrypt');

// Al crear usuario
const hashedPassword = await bcrypt.hash(password, 10);

// Al validar
const isValid = await bcrypt.compare(password, hashedPassword);
```

### 3. Frontend

- ✅ No almacenar secretos en el código
- ✅ Validar datos del lado del cliente
- ✅ Usar HTTPS
- ✅ Implementar timeout de sesión

### 4. Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 5. Actualizaciones

```bash
# Backend
cd app_backend
npm audit
npm audit fix

# Sistema
sudo apt update && sudo apt upgrade
```

---

## 📊 Monitoreo

### Logs de Aplicación

```bash
# PM2
pm2 logs app_pedidos --lines 100

# Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-13-main.log
```

### Monitoreo de Recursos

```bash
# Con PM2
pm2 monit

# Uso de disco
df -h

# Uso de memoria
free -m

# Procesos
htop
```

---

## 🔄 Actualizaciones

### Backend

```bash
cd /var/www/App_pedidos
git pull origin main
cd app_backend
npm install --production
pm2 restart app_pedidos
```

### Frontend Web

```bash
cd /var/www/App_pedidos/app_frontend
git pull origin main
flutter build web
# Copiar archivos build/web a servidor web
```

---

## �� Solución de Problemas

### Backend no inicia

```bash
# Verificar logs
pm2 logs app_pedidos

# Verificar PostgreSQL
sudo systemctl status postgresql

# Verificar puerto 3000
sudo lsof -i :3000
```

### Base de datos no conecta

```bash
# Verificar servicio
sudo systemctl status postgresql

# Verificar configuración
sudo nano /etc/postgresql/13/main/pg_hba.conf

# Reiniciar
sudo systemctl restart postgresql
```

### Error de permisos

```bash
# Ajustar permisos
sudo chown -R $USER:$USER /var/www/App_pedidos
```

---

## ✅ Checklist de Despliegue

- [ ] Servidor configurado con todas las dependencias
- [ ] PostgreSQL instalado y configurado
- [ ] Base de datos creada con esquema cargado
- [ ] Backend desplegado y corriendo con PM2
- [ ] Nginx configurado como reverse proxy
- [ ] SSL configurado con Let's Encrypt
- [ ] Variables de entorno configuradas
- [ ] Firewall configurado
- [ ] Backups automáticos configurados
- [ ] Monitoreo configurado
- [ ] Frontend web desplegado
- [ ] Apps móviles publicadas (si aplica)

---

¡Despliegue completado! 🎉
