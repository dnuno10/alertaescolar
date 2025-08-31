class Grupo {
  final String id;
  final String idEscuela;
  final String grupo; // p. ej. "1°A", "2°B"
  final String nivelEducativo; // texto tal como viene en DB
  final DateTime fechaRegistro;

  const Grupo({
    required this.id,
    required this.idEscuela,
    required this.grupo,
    required this.nivelEducativo,
    required this.fechaRegistro,
  });

  /// Factory robusto para filas devueltas por Supabase (snake_case)
  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: (json['id'] ?? '').toString(),
      idEscuela: (json['id_escuela'] ?? json['idEscuela'] ?? '').toString(),
      grupo: (json['grupo'] ?? '').toString().trim(),
      nivelEducativo: (json['nivel_educativo'] ?? json['nivelEducativo'] ?? '')
          .toString()
          .trim(),
      fechaRegistro:
          _parseDate(json['fecha_registro'] ?? json['fechaRegistro']),
    );
  }

  /// Alias por si en algún punto mapeas keys camelCase en tu app
  factory Grupo.fromCamelJson(Map<String, dynamic> json) {
    return Grupo(
      id: (json['id'] ?? '').toString(),
      idEscuela: (json['idEscuela'] ?? json['id_escuela'] ?? '').toString(),
      grupo: (json['grupo'] ?? '').toString().trim(),
      nivelEducativo: (json['nivelEducativo'] ?? json['nivel_educativo'] ?? '')
          .toString()
          .trim(),
      fechaRegistro:
          _parseDate(json['fechaRegistro'] ?? json['fecha_registro']),
    );
  }

  /// Serializa en snake_case tal como espera la BD
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_escuela': idEscuela,
      'grupo': grupo,
      'nivel_educativo': nivelEducativo,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  Grupo copyWith({
    String? id,
    String? idEscuela,
    String? grupo,
    String? nivelEducativo,
    DateTime? fechaRegistro,
  }) {
    return Grupo(
      id: id ?? this.id,
      idEscuela: idEscuela ?? this.idEscuela,
      grupo: grupo ?? this.grupo,
      nivelEducativo: nivelEducativo ?? this.nivelEducativo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  /// Validaciones simples de dominio
  bool validate() {
    if (id.isEmpty) {
      throw Exception('El ID del grupo no puede estar vacío');
    }
    if (idEscuela.isEmpty) {
      throw Exception('El grupo debe estar asociado a una escuela');
    }
    if (grupo.trim().isEmpty) {
      throw Exception('El nombre del grupo no puede estar vacío');
    }
    if (nivelEducativo.trim().isEmpty) {
      throw Exception('El nivel educativo no puede estar vacío');
    }
    return true;
    // (Dejas las validaciones de formato exacto al backend/reglas de BD)
  }

  /// Pertenece a una escuela dada
  bool belongsToSchool(String schoolId) => idEscuela == schoolId;

  /// Alias útiles para UI
  String get displayName => grupo;
  String get nivelEducativoDisplay => nivelEducativo;

  @override
  String toString() =>
      'Grupo(id: $id, grupo: $grupo, nivelEducativo: $nivelEducativo, idEscuela: $idEscuela)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Grupo && other.id == id);

  @override
  int get hashCode => id.hashCode;

  // -----------------------
  // Helpers
  // -----------------------
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }
}
