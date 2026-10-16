import 'package:flutter/material.dart';

Widget modernDataField(String label, String value) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xffF5F7FB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    child: Text(
      value.isEmpty ? "-" : value,
      style: TextStyle(
        color: value.isEmpty ? Colors.grey : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}