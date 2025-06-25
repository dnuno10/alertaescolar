# 🚀 Configuración de Notificaciones Push Reales con FCM

## 📋 Resumen

Tu aplicación ahora tiene la infraestructura completa para enviar **notificaciones push reales** usando Firebase Cloud Messaging (FCM) a través de Supabase Edge Functions.

## 🏗️ Arquitectura Implementada

```
Flutter App → Supabase Edge Function → Firebase FCM API → Dispositivos Móviles
```

### ✅ Lo que ya está implementado:

1. **FCM Service en Flutter** - Registra tokens y maneja notificaciones
2. **Supabase Edge Function** - Envía notificaciones reales usando Firebase Admin SDK
3. **Base de datos** - Tabla `mobile_tokens` para almacenar tokens FCM
4. **Fallback System** - Si la Edge Function falla, simula las notificaciones

## 🚀 Pasos para Activar Notificaciones Reales

### 1. Instalar Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Verificar instalación
supabase --version
```

### 2. Autenticarse con Supabase

```bash
# Autenticarse
supabase login

# Vincular tu proyecto
supabase link --project-ref TU_PROJECT_REF
```

### 3. Desplegar la Edge Function

```bash
# Desde la raíz de tu proyecto Flutter
supabase functions deploy send-fcm-notification
```

### 4. Configurar Permisos (Opcional)

Si necesitas restringir el acceso a la función:

```sql
-- En tu dashboard de Supabase, ejecuta:
CREATE POLICY "Allow authenticated users to send FCM" ON mobile_tokens
FOR SELECT USING (auth.role() = 'authenticated');
```

### 5. Probar las Notificaciones

1. **Ejecuta tu app Flutter**
2. **Inicia sesión como usuario no-admin** (para registrar token FCM)
3. **Desde panel admin, envía una notificación**
4. **¡Deberías recibir la notificación real en tu dispositivo!**

## 🔧 Verificación y Troubleshooting

### Verificar que la Edge Function esté desplegada:

```bash
supabase functions list
```

### Ver logs de la Edge Function:

```bash
supabase functions logs send-fcm-notification
```

### Verificar tokens en la base de datos:

```sql
SELECT * FROM mobile_tokens ORDER BY created_at DESC;
```

## 📱 Comportamiento Esperado

### ✅ Con Edge Function Funcionando:
```
FCM: 🚀 REAL PUSH NOTIFICATIONS SENT! 🚀
FCM: Total tokens: 1
FCM: Successful: 1
FCM: Failed: 0
FCM: 🎉 Real push notifications delivered successfully!
```

### ⚠️ Con Edge Function No Disponible (Fallback):
```
FCM: Error calling Edge Function: [error]
FCM: Falling back to local simulation...
FCM: 📱 SIMULATED NOTIFICATION RECEIVED! 📱
```

## 🔐 Seguridad

- **Firebase Admin SDK Key**: Está integrada directamente en la Edge Function
- **Tokens FCM**: Se almacenan de forma segura en Supabase
- **Autenticación**: Solo usuarios autenticados pueden activar notificaciones

## 📊 Monitoreo

### Logs en Flutter:
- `FCM: 🚀 REAL PUSH NOTIFICATIONS SENT!` = Notificaciones reales enviadas
- `FCM: 📱 SIMULATED NOTIFICATION RECEIVED!` = Fallback (simulación)

### Logs en Supabase:
- Ve a tu dashboard → Functions → send-fcm-notification → Logs

## 🎯 Próximos Pasos

1. **Despliega la Edge Function** siguiendo los pasos arriba
2. **Prueba enviando notificaciones** desde el panel admin
3. **Verifica que lleguen a tu dispositivo físico**
4. **Monitorea los logs** para confirmar el funcionamiento

## ❓ Troubleshooting Común

### "Edge Function not found"
- Verifica que esté desplegada: `supabase functions list`
- Redespliega: `supabase functions deploy send-fcm-notification`

### "No tokens found"
- Verifica que el usuario esté logueado como no-admin
- Revisa la tabla `mobile_tokens` en tu base de datos

### "Firebase error"
- Verifica que el proyecto Firebase esté activo
- Confirma que FCM esté habilitado en Firebase Console

---

¡Una vez que despliegues la Edge Function, tus notificaciones push serán **100% reales**! 🎉 