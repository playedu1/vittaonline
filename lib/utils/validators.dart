class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    final trimmedValue = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}
