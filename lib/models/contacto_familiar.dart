import '../l10n/app_localizations.dart';

/// Valores alineados con lo que almacenamos en la columna `parentesco` (TEXT).
/// Si en la BD guardas exactamente estos nombres (en minúsculas/camelCase), queda 1:1.
enum TipoParentesco {
  padre,
  madre,
  abuelo,
  abuela,
  tutor,
  tutora,
  tio,
  tia,
  hermano,
  hermana,
  otroFamiliar,
}

/// Extensión para nombre localizado del parentesco
extension TipoParentescoExtension on TipoParentesco {
  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case TipoParentesco.padre:
        return l10n.father;
      case TipoParentesco.madre:
        return l10n.mother;
      case TipoParentesco.abuelo:
        return l10n.grandfather;
      case TipoParentesco.abuela:
        return l10n.grandmother;
      case TipoParentesco.tutor:
      case TipoParentesco.tutora:
        return l10n.tutor;
      case TipoParentesco.tio:
        return l10n.uncle;
      case TipoParentesco.tia:
        return l10n.aunt;
      case TipoParentesco.hermano:
        return l10n.brother;
      case TipoParentesco.hermana:
        return l10n.sister;
      case TipoParentesco.otroFamiliar:
        return l10n.otherFamily;
    }
  }
}

class ContactoFamiliar {
  /// === Columnas reales en la tabla `contactos_familiares` ===
  /// id (pk uuid), id_usuario (fk uuid), nombre (text), parentesco (text),
  /// telefono (text/null), email (text/null), fecha_registro (timestamptz)
  final String id;
  final String usuarioId; // id_usuario
  final String nombre;
  final TipoParentesco parentesco;
  final String? telefono; // puede ser NULL en BD
  final String? email; // puede ser NULL en BD
  final DateTime fechaRegistro; // fecha_registro

  const ContactoFamiliar({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.parentesco,
    this.telefono,
    this.email,
    required this.fechaRegistro,
  });

  // -------------------------
  //        APP <-> JSON
  // -------------------------
  factory ContactoFamiliar.fromJson(Map<String, dynamic> json) {
    return ContactoFamiliar(
      id: (json['id'] ?? '').toString(),
      usuarioId: (json['usuarioId'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      parentesco: _parentescoFromString(json['parentesco']),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      fechaRegistro: _parseDate(json['fechaRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'parentesco': parentesco.name,
      'telefono': telefono,
      'email': email,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  // -------------------------
  //       BD <-> MAP
  //  (respeta snake_case)
  // -------------------------
  factory ContactoFamiliar.fromDbMap(Map<String, dynamic> row) {
    return ContactoFamiliar(
      id: (row['id'] ?? '').toString(),
      usuarioId: (row['id_usuario'] ?? '').toString(),
      nombre: (row['nombre'] ?? '').toString(),
      parentesco: _parentescoFromString(row['parentesco']),
      telefono: row['telefono']?.toString(),
      email: row['email']?.toString(),
      fechaRegistro: _parseDate(row['fecha_registro']),
    );
  }

  /// Mapa listo para `insert`/`upsert` en Supabase.
  /// Incluye todas las columnas habituales.
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'id_usuario': usuarioId,
      'nombre': nombre,
      'parentesco': parentesco.name,
      'telefono': telefono,
      'email': email,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  /// Mapa recomendado para `update` (sin tocar claves ni fecha_registro).
  Map<String, dynamic> toDbUpdateMap() {
    return {
      'nombre': nombre,
      'parentesco': parentesco.name,
      'telefono': telefono,
      'email': email,
    };
  }

  ContactoFamiliar copyWith({
    String? id,
    String? usuarioId,
    String? nombre,
    TipoParentesco? parentesco,
    String? telefono,
    String? email,
    DateTime? fechaRegistro,
  }) {
    return ContactoFamiliar(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      parentesco: parentesco ?? this.parentesco,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  // -------------------------
  //     Helpers y validación
  // -------------------------
  static TipoParentesco _parentescoFromString(dynamic value) {
    final raw = (value ?? '').toString().trim();
    // intento directo con enum.name
    final hit = TipoParentesco.values.where((e) => e.name == raw).toList();
    if (hit.isNotEmpty) return hit.first;

    // normalización: espacios/guiones/underscores mayúsculas
    final norm = raw.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    for (final e in TipoParentesco.values) {
      final en = e.name.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
      if (en == norm) return e;
    }
    return TipoParentesco.otroFamiliar;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now().toUtc();
    final s = value.toString();
    if (s.isEmpty) return DateTime.now().toUtc();
    try {
      return DateTime.parse(s);
    } catch (_) {
      // Si llega en formato inesperado, evita romper la UI
      return DateTime.now().toUtc();
    }
  }

  /// Normaliza el teléfono para almacenar de forma consistente.
  /// Conserva solo dígitos y `+` (elimina espacios/guiones/caracteres).
  static String normalizePhone(String input) {
    return input.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return true; // opcional
    final p = normalizePhone(phone);
    // 8–15 dígitos, opcional prefijo +
    return RegExp(r'^\+?\d{8,15}$').hasMatch(p);
  }

  static bool isValidEmail(String? mail) {
    if (mail == null || mail.isEmpty) return true; // opcional
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(mail);
  }

  @override
  String toString() {
    return 'ContactoFamiliar(id: $id, usuarioId: $usuarioId, nombre: $nombre, parentesco: ${parentesco.name}, telefono: $telefono, email: $email)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ContactoFamiliar && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
