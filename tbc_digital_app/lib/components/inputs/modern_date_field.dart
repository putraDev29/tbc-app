import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

Widget modernDateField(
  String label,
  DateTime? value,
  Function(DateTime) onPicked, {
  bool required = true,
}) {
  return FormField<DateTime>(
    initialValue: value,
    validator: (val) {
      if (required && val == null) {
        return "$label wajib diisi";
      }
      return null;
    },
    builder: (state) {
      if (value != state.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.didChange(value);
          }
        });
      }

      String text = "";

      if (state.value != null) {
        final v = state.value!;
        text =
            "${v.day.toString().padLeft(2, '0')}-${v.month.toString().padLeft(2, '0')}-${v.year}";
      }

      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: state.context,
            initialDate: state.value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );

          if (picked != null) {
            state.didChange(picked);
            onPicked(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: required ? "$label *" : label,
            filled: true,
            fillColor: Colors.white,
            errorText: state.errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          child: Text(
            text.isEmpty ? "Pilih tanggal" : text,
            style: TextStyle(color: text.isEmpty ? Colors.grey : Colors.black),
          ),
        ),
      );
    },
  );
}
