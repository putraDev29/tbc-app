import 'package:flutter/material.dart';

Widget modernInputField(
  String label,
  TextEditingController controller, {
  bool readOnly = false,
  bool isNumber = false,
  bool required = true, // 🔥 default wajib
}) {
  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    validator: (value) {
      if (required && (value == null || value.trim().isEmpty)) {
        return "$label wajib diisi";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: required ? "$label *" : label, // 🔥 kasih tanda *
      filled: true,
      fillColor: Colors.white,

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
    ),
  );
}
