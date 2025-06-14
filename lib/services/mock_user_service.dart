import '../models/models.dart';

class MockUserService {
  // Simular delay de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Usuario mock actual
  static final Usuario _currentUser = Usuario(
    id: '',
    nombre: '',
    apellido: '',
    email: '',
    telefono: '',
    tipo: TipoUsuario.padre,
    fechaRegistro: DateTime.now().subtract(const Duration(days: 180)),
  );

  Future<Usuario> getCurrentUser() async {
    await _simulateNetworkDelay();
    return _currentUser;
  }

  Future<Usuario> updateUser(Usuario user) async {
    await _simulateNetworkDelay();

    // Simular actualización exitosa
    return user.copyWith(
      // Mantener algunos campos que no se pueden cambiar
      id: _currentUser.id,
      fechaRegistro: _currentUser.fechaRegistro,
    );
  }

  Future<bool> validateEmail(String email) async {
    await _simulateNetworkDelay();

    // Simular validación de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> validatePhone(String phone) async {
    await _simulateNetworkDelay();

    // Simular validación de teléfono
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }
}
