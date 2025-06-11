enum TipoEscuela { publica, privada, mixta }

enum NivelEducativo { preescolar, primaria, secundaria, bachillerato, mixto }

class Escuela {
  final String id;
  final String nombre;
  final String codigo;
  final TipoEscuela tipo;
  final List<NivelEducativo> nivelesEducativos;
  final String direccion;
  final String telefono;
  final String email;
  final String? logoUrl;
  final Map<String, String> coloresInstitucionales;
  final bool activa;
  final DateTime fechaRegistro;
  final DateTime? fechaUltimaActualizacion;
  final Map<String, dynamic> horarios;

  const Escuela({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipo,
    required this.nivelesEducativos,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.logoUrl,
    this.coloresInstitucionales = const {},
    this.activa = true,
    required this.fechaRegistro,
    this.fechaUltimaActualizacion,
    this.horarios = const {},
  });

  factory Escuela.fromJson(Map<String, dynamic> json) {
    return Escuela(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: TipoEscuela.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoEscuela.publica,
      ),
      nivelesEducativos: (json['nivelesEducativos'] as List? ?? [])
          .map((e) => NivelEducativo.values.firstWhere(
                (nivel) => nivel.name == e,
                orElse: () => NivelEducativo.primaria,
              ))
          .toList(),
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      logoUrl: json['logoUrl'],
      coloresInstitucionales:
          Map<String, String>.from(json['coloresInstitucionales'] ?? {}),
      activa: json['activa'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      fechaUltimaActualizacion: json['fechaUltimaActualizacion'] != null
          ? DateTime.parse(json['fechaUltimaActualizacion'])
          : null,
      horarios: Map<String, dynamic>.from(json['horarios'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'tipo': tipo.name,
      'nivelesEducativos': nivelesEducativos.map((e) => e.name).toList(),
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'logoUrl': logoUrl,
      'coloresInstitucionales': coloresInstitucionales,
      'activa': activa,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'fechaUltimaActualizacion': fechaUltimaActualizacion?.toIso8601String(),
      'horarios': horarios,
    };
  }

  Escuela copyWith({
    String? id,
    String? nombre,
    String? codigo,
    TipoEscuela? tipo,
    List<NivelEducativo>? nivelesEducativos,
    String? direccion,
    String? telefono,
    String? email,
    String? logoUrl,
    Map<String, String>? coloresInstitucionales,
    bool? activa,
    DateTime? fechaRegistro,
    DateTime? fechaUltimaActualizacion,
    Map<String, dynamic>? horarios,
  }) {
    return Escuela(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      nivelesEducativos: nivelesEducativos ?? this.nivelesEducativos,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      coloresInstitucionales:
          coloresInstitucionales ?? this.coloresInstitucionales,
      activa: activa ?? this.activa,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaUltimaActualizacion:
          fechaUltimaActualizacion ?? this.fechaUltimaActualizacion,
      horarios: horarios ?? this.horarios,
    );
  }

  bool get tieneHorarios => horarios.isNotEmpty;
  bool get tieneColoresPersonalizados => coloresInstitucionales.isNotEmpty;
  bool get tieneUltimaActualizacion => fechaUltimaActualizacion != null;

  @override
  String toString() {
    return 'Escuela(id: $id, nombre: $nombre, codigo: $codigo, activa: $activa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Escuela && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
