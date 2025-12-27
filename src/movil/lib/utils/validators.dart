class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese un correo';
    if (!value.contains('@')) return 'Correo no válido';
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Ingrese una contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}
