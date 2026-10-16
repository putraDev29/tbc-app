import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

Widget modernDropdown(
  String label,
  String? value,
  List<String> items,
  Function(String) onChanged, {
  bool required = true,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down),

    style: const TextStyle(fontSize: 14, color: Colors.black),

    validator: (val) {
      if (required && (val == null || val.isEmpty)) {
        return "$label wajib dipilih";
      }
      return null;
    },

    decoration: InputDecoration(
      labelText: required ? "$label *" : label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),

      // 🔥 error style
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),

    items: items
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 14)),
          ),
        )
        .toList(),

    onChanged: (val) => onChanged(val!),
  );
}