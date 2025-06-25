# FCM Service Setup - Mobile App Implementation

This project uses a **simplified FCM implementation** designed specifically for Flutter mobile applications. The current implementation focuses on token management and notification structure while providing a foundation for future server-side FCM integration.

## Current Implementation Status

### ✅ **Implemented Features**
- FCM token registration for non-admin users only
- Automatic token refresh handling
- Token storage in `mobile_tokens` database table
- Notification data structure and recipient resolution
- Support for all recipient types (individual, group, shift, all students)
- Database notification creation with proper relationships

### 🔄 **Simplified FCM Approach**
Due to the complexity of implementing proper JWT signing and service account authentication in Flutter mobile apps, the current implementation uses a **simplified approach**:

- **Token Management**: ✅ Fully functional
- **Database Notifications**: ✅ Fully functional  
- **Push Notification Sending**: 📝 Simulated (logs only)

## Database Structure

### `mobile_tokens` Table
```sql
- id (uuid) - Primary key
- id_usuario (uuid) - User's ID (foreign key to usuarios)
- token (text) - FCM device token
- created_at (timestamp) - Creation timestamp
```

## How It Currently Works

### 1. **Token Registration**
- Only non-admin users get FCM tokens registered
- Tokens are automatically refreshed when needed
- Invalid/expired tokens are cleaned up

### 2. **Notification Flow**
```
Scanner/Admin Action → Database Notification → FCM Token Resolution → [Simulated Push Send]
```

### 3. **Recipient Types Supported**
- **Individual**: Direct student selection
- **Group**: Multiple group selection  
- **Shift**: All students in a shift
- **All Students**: Entire school

### 4. **Database Relationships**
```
alumnos → alumno_tutores → usuarios → mobile_tokens
```

## Production Recommendations

For **production deployment**, implement one of these approaches:

### Option 1: Backend Service (Recommended)
```
Mobile App → Backend API → FCM Server → Push Notifications
```

### Option 2: Firebase Functions
```
Database Trigger → Firebase Function → FCM API → Push Notifications
```

### Option 3: Server-Side JWT Implementation
- Implement proper RSA key signing for JWT tokens
- Use the existing service account file with server-side code

## Current Service Account File

The project includes:
```
alerta-escolar-1e870-firebase-adminsdk-kymho-7c00fddcd5.json
```

This file is ready for use with any of the production approaches above.

## Testing the Current Implementation

1. **Run the app** - FCM tokens will be registered for non-admin users
2. **Send notifications** - Database notifications are created successfully
3. **Check logs** - FCM service logs show token resolution and simulated sends
4. **Verify database** - Check `mobile_tokens` and `notificaciones` tables

## Migration Path

When ready for production push notifications:

1. Choose one of the production approaches above
2. Replace the `_sendNotificationsUsingLegacyAPI` method
3. Implement proper FCM HTTP v1 API calls
4. Test with real devices

## Benefits of Current Approach

- ✅ **No complex dependencies** - Avoids mobile JWT signing issues
- ✅ **Database functionality complete** - All notification logic works
- ✅ **Token management ready** - FCM tokens properly collected and managed
- ✅ **Easy migration** - Simple to upgrade to full FCM when needed
- ✅ **Development friendly** - Can test all flows without server setup

The current implementation provides a **solid foundation** for FCM notifications while avoiding the complexity of mobile-side service account authentication. 