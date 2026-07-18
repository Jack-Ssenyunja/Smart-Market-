String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required.';
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required.';
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (value.length < 6) return 'Password must be at least 6 characters.';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone number is required.';
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9) return 'Enter a valid phone number.';
  return null;
}

String? validateNumber(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required.';
  if (double.tryParse(value) == null) return 'Enter a valid number.';
  return null;
}
