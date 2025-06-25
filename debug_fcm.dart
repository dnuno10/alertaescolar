import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (you'll need to replace with your actual credentials)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(FCMDebugApp());
}

class FCMDebugApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Debug',
      home: FCMDebugScreen(),
    );
  }
}

class FCMDebugScreen extends StatefulWidget {
  @override
  _FCMDebugScreenState createState() => _FCMDebugScreenState();
}

class _FCMDebugScreenState extends State<FCMDebugScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String _debugInfo = 'Iniciando diagnóstico...';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _debugInfo = 'Ejecutando diagnósticos FCM...\n\n';
    });

    try {
      // 1. Check mobile_tokens table
      _addDebugInfo('🔍 Verificando tokens en la base de datos...');
      final tokensResponse = await _supabase
          .from('mobile_tokens')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);

      _addDebugInfo('📱 Tokens encontrados: ${tokensResponse.length}');
      for (var token in tokensResponse) {
        _addDebugInfo('  - Usuario: ${token['id_usuario']}');
        _addDebugInfo('  - Token: ${token['token'].substring(0, 20)}...');
        _addDebugInfo('  - Fecha: ${token['created_at']}');
        _addDebugInfo('');
      }

      // 2. Check recent notifications
      _addDebugInfo('📧 Verificando notificaciones recientes...');
      final notificationsResponse = await _supabase
          .from('notificaciones')
          .select('*')
          .order('fecha_registro', ascending: false)
          .limit(5);

      _addDebugInfo(
          '📬 Notificaciones recientes: ${notificationsResponse.length}');
      for (var notification in notificationsResponse) {
        _addDebugInfo('  - Título: ${notification['titulo']}');
        _addDebugInfo('  - Tipo: ${notification['tipo_notificacion']}');
        _addDebugInfo('  - Fecha: ${notification['fecha_registro']}');
        _addDebugInfo('');
      }

      // 3. Test Edge Function directly
      _addDebugInfo('🚀 Probando Edge Function directamente...');
      await _testEdgeFunction();
    } catch (e) {
      _addDebugInfo('❌ Error en diagnóstico: $e');
    }
  }

  Future<void> _testEdgeFunction() async {
    try {
      // Get a test token
      final tokensResponse = await _supabase
          .from('mobile_tokens')
          .select('token')
          .limit(1)
          .maybeSingle();

      if (tokensResponse == null) {
        _addDebugInfo('⚠️ No hay tokens para probar');
        return;
      }

      final testToken = tokensResponse['token'] as String;
      _addDebugInfo(
          '🧪 Usando token de prueba: ${testToken.substring(0, 20)}...');

      // Call Edge Function
      final response = await _supabase.functions.invoke(
        'send-fcm-notification',
        body: {
          'tokens': [testToken],
          'title': 'Prueba FCM Debug',
          'body': 'Esta es una notificación de prueba desde el script de debug',
          'data': {
            'test': 'true',
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      );

      _addDebugInfo('📤 Respuesta de Edge Function:');
      _addDebugInfo('  - Status: ${response.status}');
      _addDebugInfo('  - Data: ${response.data}');

      if (response.data != null) {
        final result = response.data as Map<String, dynamic>;
        _addDebugInfo('  - Exitosos: ${result['successCount'] ?? 0}');
        _addDebugInfo('  - Fallidos: ${result['failureCount'] ?? 0}');

        if (result['results'] != null) {
          final results = result['results'] as List;
          for (var tokenResult in results) {
            if (tokenResult['success'] == true) {
              _addDebugInfo('  ✅ Token procesado exitosamente');
            } else {
              _addDebugInfo('  ❌ Error: ${tokenResult['error']}');
            }
          }
        }
      }
    } catch (e) {
      _addDebugInfo('❌ Error probando Edge Function: $e');
    }
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _runDiagnostics,
                  child: Text('Ejecutar Diagnóstico'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _debugInfo = '';
                    });
                  },
                  child: Text('Limpiar'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
