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

class ContactoFamiliar {
  final String id;
  final String usuarioId;
  final String nombre;
  final TipoParentesco parentesco;
  final String telefono;
  final String? email;
  final DateTime fechaRegistro;

  const ContactoFamiliar({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.parentesco,
    required this.telefono,
    this.email,
    required this.fechaRegistro,
  });

  factory ContactoFamiliar.fromJson(Map<String, dynamic> json) {
    return ContactoFamiliar(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      nombre: json['nombre'] ?? '',
      parentesco: TipoParentesco.values.firstWhere(
        (e) => e.name == json['parentesco'],
        orElse: () => TipoParentesco.otroFamiliar,
      ),
      telefono: json['telefono'] ?? '',
      email: json['email'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'parentesco': parentesco.name,
      'telefono': telefono,
      'email': email,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  ContactoFamiliar copyWith({
    String? id,
    String? nombre,
    TipoParentesco? parentesco,
    String? telefono,
    String? email,
    bool? esPrincipal,
    DateTime? fechaRegistro,
  }) {
    return ContactoFamiliar(
      id: id ?? this.id,
      usuarioId: this.usuarioId,
      nombre: nombre ?? this.nombre,
      parentesco: parentesco ?? this.parentesco,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'ContactoFamiliar(id: $id, nombre: $nombre, parentesco: $parentesco, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactoFamiliar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
