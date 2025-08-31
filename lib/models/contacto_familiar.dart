import '../l10n/app_localizations.dart';

/// Valores alineados con lo que almacenamos en la columna `parentesco` (TEXT).
/// Si en la BD guardas exactamente estos nombres (en minúsculas), quedará 1:1.
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
  /// id (pk, uuid), id_usuario (fk uuid), nombre (text), parentesco (text),
  /// telefono (text/null), email (text/null), fecha_registro (timestamptz)
  final String id;
  final String usuarioId; // id_usuario
  final String nombre;
  final TipoParentesco parentesco;
  final String? telefono; // Puede ser NULL en BD
  final String? email; // Puede ser NULL en BD
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
  // (útil si en el app layer usas camelCase)
  // -------------------------
  factory ContactoFamiliar.fromJson(Map<String, dynamic> json) {
    return ContactoFamiliar(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      nombre: json['nombre'] ?? '',
      parentesco: _parentescoFromString(json['parentesco']),
      telefono: json['telefono'],
      email: json['email'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
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
      fechaRegistro: DateTime.parse(row['fecha_registro'].toString()),
    );
  }

  /// Mapa listo para `insert`/`update` en Supabase.
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
    // intentamos machacar directo con el enum.name
    final hit = TipoParentesco.values.where((e) => e.name == raw).toList();
    if (hit.isNotEmpty) return hit.first;

    // normalización por si llegan variantes (ej: 'otro_familiar', 'OTROFAMILIAR', etc.)
    final norm = raw.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    for (final e in TipoParentesco.values) {
      final en = e.name.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      if (en == norm) return e;
    }
    return TipoParentesco.otroFamiliar;
  }

  static bool isValidPhone(String? phone) {
    if (phone == null) return true; // es opcional
    final p = phone.replaceAll(RegExp(r'\s+'), '');
    // Valida 8–15 dígitos (con posible + al inicio)
    return RegExp(r'^\+?\d{8,15}$').hasMatch(p);
  }

  static bool isValidEmail(String? mail) {
    if (mail == null || mail.isEmpty) return true; // opcional
    return RegExp(
      r"^[^\s@]+@[^\s@]+\.[^\s@]+$",
    ).hasMatch(mail);
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
