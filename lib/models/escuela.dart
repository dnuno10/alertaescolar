enum TipoEscuela { publica, privada, mixta }

enum NivelEducativo { preescolar, primaria, secundaria, bachillerato }

class Escuela {
  final String id;
  final String nombre;
  final String codigo;
  final TipoEscuela tipo;
  final List<NivelEducativo> nivelesEducativos;
  final String direccion;
  final String telefono;
  final String email;
  final String? sitioWeb;
  final String? descripcion;
  final DateTime fechaRegistro;

  const Escuela({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipo,
    required this.nivelesEducativos,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.sitioWeb,
    this.descripcion,
    required this.fechaRegistro,
  });

  factory Escuela.fromJson(Map<String, dynamic> json) {
    // Convert boolean education level flags to enum list
    List<NivelEducativo> niveles = [];
    if (json['preescolar'] == true) {
      niveles.add(NivelEducativo.preescolar);
    }
    if (json['primaria'] == true) {
      niveles.add(NivelEducativo.primaria);
    }
    if (json['secundaria'] == true) {
      niveles.add(NivelEducativo.secundaria);
    }
    if (json['preparatoria'] == true) {
      // Use 'preparatoria' field from DB for bachillerato level
      niveles.add(NivelEducativo.bachillerato);
    }

    // Default to primaria if no levels are selected
    if (niveles.isEmpty) {
      niveles.add(NivelEducativo.primaria);
    }

    return Escuela(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: TipoEscuela.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoEscuela.publica,
      ),
      nivelesEducativos: niveles,
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      sitioWeb: json['sitio_web'],
      descripcion: json['descripcion'],
      fechaRegistro: DateTime.parse(
          json['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'tipo': tipo.name,
      // Convert education level enums to boolean fields for database
      'preescolar': nivelesEducativos.contains(NivelEducativo.preescolar),
      'primaria': nivelesEducativos.contains(NivelEducativo.primaria),
      'secundaria': nivelesEducativos.contains(NivelEducativo.secundaria),
      'preparatoria': nivelesEducativos.contains(
          NivelEducativo.bachillerato), // Use 'preparatoria' field in DB
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sitio_web': sitioWeb,
      'descripcion': descripcion,
      'fecha_registro': fechaRegistro.toIso8601String(),
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
    String? sitioWeb,
    String? descripcion,
    DateTime? fechaRegistro,
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
      sitioWeb: sitioWeb ?? this.sitioWeb,
      descripcion: descripcion ?? this.descripcion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'Escuela(id: $id, nombre: $nombre, codigo: $codigo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Escuela && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
