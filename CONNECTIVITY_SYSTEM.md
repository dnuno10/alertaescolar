# Sistema de Conectividad Global - Alerta Escolar

## Descripción

Este sistema implementa una detección automática de conectividad a internet que funciona globalmente en toda la aplicación. Cuando se pierde la conexión, automáticamente se muestra una vista de "Sin conexión a Internet" con opción de reintentar.

## Componentes

### 1. ConnectivityProvider (`lib/providers/connectivity_provider.dart`)

- Monitorea constantemente el estado de la conexión a internet
- Notifica a la app cuando hay cambios en la conectividad
- Proporciona métodos para verificar manualmente la conexión

### 2. ConnectivityWrapper (`lib/widgets/connectivity_wrapper.dart`)

- **ConnectivityWrapper**: Para uso en vistas específicas
- **GlobalConnectivityWrapper**: Para uso global en toda la app

### 3. NoInternetView (`lib/views/auth/no_internet_view.dart`)

- Vista mejorada que muestra cuando no hay conexión
- Incluye botón de "Reintentar" con feedback visual
- Verifica automáticamente la conectividad al intentar reconectar

## Funcionamiento

### Detección Automática

- El sistema detecta automáticamente cambios en la conectividad
- No requiere intervención manual del usuario
- Funciona en segundo plano sin afectar el rendimiento

### Vista Global

- Cuando se pierde la conexión, se muestra una overlay sobre la vista actual
- La vista actual se mantiene pero se deshabilita
- Al restaurarse la conexión, la app regresa automáticamente a la vista normal

### Botón Reintentar

- Verifica manualmente la conectividad
- Muestra feedback visual mientras verifica
- Informa al usuario si aún no hay conexión

## Implementación

### En main.dart

```dart
// La app se envuelve automáticamente con GlobalConnectivityWrapper
builder: (context, child) {
  return GlobalConnectivityWrapper(child: child ?? Container());
},
```

### En ProviderManager

```dart
// ConnectivityProvider se incluye automáticamente en todos los providers
ChangeNotifierProvider<ConnectivityProvider>.value(
    value: _connectivityProvider),
```

### Uso en Vistas Específicas (Opcional)

```dart
ConnectivityWrapper(
  child: MyView(),
  onRetry: () {
    // Lógica personalizada al reintentar
  },
)
```

## Características

✅ **Detección Automática**: No requiere intervención manual
✅ **Global**: Funciona en toda la app, independientemente de la vista
✅ **Botón Reintentar**: Permite verificación manual de la conexión
✅ **Feedback Visual**: Muestra estado de carga al reintentar
✅ **Reconexión Automática**: La app se restaura automáticamente cuando hay conexión
✅ **Sin Interrupciones**: Mantiene el estado de la vista actual
✅ **Logs de Debug**: Para monitoreo en desarrollo

## Estados de Conectividad

1. **Conectado**: App funciona normalmente
2. **Desconectado**: Se muestra vista de "Sin Internet"
3. **Verificando**: Estado temporal al reintentar conexión
4. **Reconectado**: App regresa automáticamente al estado normal

## Ventajas

- **Experiencia de Usuario Mejorada**: Feedback claro sobre el estado de la conexión
- **Detección Robusta**: Funciona en cualquier parte de la app
- **Recuperación Automática**: No requiere reiniciar la app
- **Código Limpio**: Sistema centralizado y reutilizable
- **Performance**: Monitoreo eficiente sin impacto en rendimiento
