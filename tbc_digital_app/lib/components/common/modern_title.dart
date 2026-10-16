import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

Widget modernTitle(IconData icon, String title, dynamic value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: Color(0xFF7FB77E)),
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(value?.toString() ?? "-"),
      ],
    ),
  );
}
