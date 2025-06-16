class Grupo {
  final String id;
  final String idEscuela;
  final String grupo;
  final String nivelEducativo;
  final DateTime fechaRegistro;

  const Grupo({
    required this.id,
    required this.idEscuela,
    required this.grupo,
    required this.nivelEducativo,
    required this.fechaRegistro,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] ?? '',
      idEscuela: json['id_escuela'] ?? '',
      grupo: json['grupo'] ?? '',
      nivelEducativo: json['nivel_educativo'] ?? '',
      fechaRegistro: DateTime.parse(
          json['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

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

  /// Validates the grupo data
  /// Returns true if all validations pass, or throws an exception with the error message
  bool validate() {
    if (id.isEmpty) {
      throw Exception('El ID del grupo no puede estar vacío');
    }

    if (idEscuela.isEmpty) {
      throw Exception('El grupo debe estar asociado a una escuela');
    }

    if (grupo.isEmpty) {
      throw Exception('El nombre del grupo no puede estar vacío');
    }

    if (nivelEducativo.isEmpty) {
      throw Exception('El nivel educativo no puede estar vacío');
    }

    return true;
  }

  /// Validates that this grupo belongs to the specified school
  bool belongsToSchool(String schoolId) {
    return idEscuela == schoolId;
  }

  /// Get display name for the group (e.g., "1°A", "2°B")
  String get displayName => grupo;

  /// Get educational level display name
  String get nivelEducativoDisplay => nivelEducativo;

  @override
  String toString() {
    return 'Grupo(id: $id, grupo: $grupo, nivelEducativo: $nivelEducativo, idEscuela: $idEscuela)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grupo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
