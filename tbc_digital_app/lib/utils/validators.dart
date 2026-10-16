/// Common input validators for form fields
class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'Bidang ini']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^[0-9+]{9,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Nomor HP tidak valid (9-15 digit angka)';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Karakter']) {
    if (value == null || value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }
}

