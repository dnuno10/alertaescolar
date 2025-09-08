// models/escuela.dart
// Alineado a public.escuelas del SQL proporcionado.
// Columnas: id, nombre, codigo, tipo, direccion, telefono, email, fecha_registro, descripcion, sitio_web

enum TipoEscuela { publica, privada, mixta }

class Escuela {
  final String id;
  final String nombre;
  final String? codigo; // NULL en BD
  final TipoEscuela tipo; // text en BD: "publica" | "privada" | "mixta"
  final String direccion;
  final String telefono;
  final String email;
  final String? sitioWeb; // sitio_web en BD
  final String? descripcion; // descripcion en BD
  final DateTime
      fechaRegistro; // fecha_registro (GENERADO por BD, solo lectura)

  const Escuela({
    required this.id,
    required this.nombre,
    this.codigo,
    required this.tipo,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.sitioWeb,
    this.descripcion,
    required this.fechaRegistro,
  });

  /// Mapea el string de BD a enum, tolerante a mayúsculas/minúsculas.
  static TipoEscuela _tipoFromDb(String? value) {
    final v = (value ?? '').toLowerCase().trim();
    switch (v) {
      case 'privada':
        return TipoEscuela.privada;
      case 'mixta':
        return TipoEscuela.mixta;
      case 'publica':
      default:
        return TipoEscuela.publica;
    }
  }

  factory Escuela.fromJson(Map<String, dynamic> json) {
    return Escuela(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      codigo: json['codigo'] as String?,
      tipo: _tipoFromDb(json['tipo'] as String?),
      direccion: (json['direccion'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      sitioWeb: json['sitio_web'] as String?,
      descripcion: json['descripcion'] as String?,
      fechaRegistro:
          DateTime.tryParse((json['fecha_registro'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  /// Payload para UPDATE/INSERT a Supabase.
  /// Importante: **NO** incluir `id` ni `fecha_registro` (ambas controladas por BD).
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'tipo': tipo.name, // "publica" | "privada" | "mixta"
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sitio_web': sitioWeb,
      'descripcion': descripcion,
      // 'fecha_registro':  // ← NO enviar, lo maneja la BD
      // 'id':              // ← NO enviar en update; se usa en .eq('id', ...)
    };
  }

  /// Útil para depuración (no usar para update).
  Map<String, dynamic> toDebugMap() {
    return {
      'id': id,
      ...toJson(),
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  Escuela copyWith({
    String? id,
    String? nombre,
    String? codigo,
    TipoEscuela? tipo,
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
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      descripcion: descripcion ?? this.descripcion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() => 'Escuela(id: $id, nombre: $nombre, tipo: ${tipo.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Escuela && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
