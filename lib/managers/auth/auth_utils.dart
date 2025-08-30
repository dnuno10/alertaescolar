// lib/managers/auth/auth_utils.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alertaescolar/models/usuario.dart';
import 'package:alertaescolar/models/models.dart'; // por TipoUsuario si está aquí

/// Crea o asegura el registro mínimo en 'usuarios' para el user autenticado.
/// - Inserta si no existe (rellena con strings vacíos).
/// - Si existe por email o por id, lo devuelve.
/// - Retorna el Usuario (con al menos id/email/fecha_registro).
Future<Usuario> ensureUserRow({
  required SupabaseClient supabase,
  required User authUser,
  TipoUsuario defaultTipo = TipoUsuario.padre,
}) async {
  final String id = authUser.id;
  final String email = (authUser.email ?? '').trim().toLowerCase();

  // 1) Intenta encontrar por id
  Map<String, dynamic>? row =
      await supabase.from('usuarios').select('*').eq('id', id).maybeSingle();

  // 2) Si no hay por id y sí tienes email, intenta por email
  if (row == null && email.isNotEmpty) {
    row = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .maybeSingle();
  }

  // 3) Si no existe, inserta registro mínimo
  if (row == null) {
    final nowUtc = DateTime.now().toUtc();
    final payload = {
      'id': id,
      'email': email, // puede venir vacío y está bien
      'nombre': '', // placeholder
      'apellido': '', // placeholder
      'tipo': defaultTipo.name, // placeholder (luego se puede actualizar)
      'fecha_registro': nowUtc.toIso8601String(),
    };

    // Usa upsert por seguridad/competencia de claves (id/email únicos).
    row = await supabase
        .from('usuarios')
        .upsert(payload, onConflict: 'id')
        .select()
        .maybeSingle();
  }

  // 4) Normaliza retorno a tu modelo
  return Usuario.fromJson(row!);
}
