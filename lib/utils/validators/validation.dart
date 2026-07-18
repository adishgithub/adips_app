class AdipsValidator {
  AdipsValidator._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Enter a valid name';
    }
    return null;
  }

  static String? validateRequired(dynamic value, {String fieldName = 'This field'}) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }
}