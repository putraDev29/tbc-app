import 'package:flutter/material.dart';

Widget pasienCard(
  BuildContext context,
  Map<String, dynamic> pasien,
  VoidCallback onDetail,
  VoidCallback onEdit,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(width: 12),

        /// 🔹 DATA PASIEN
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pasien["nama"] ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Umur: ${pasien["umur"] ?? "-"} | ${pasien["alamat"] ?? "-"}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        /// 🔹 BUTTON AKSI
        Row(
          children: [
            /// 🔍 DETAIL
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: onDetail,
            ),

            /// ✏️ EDIT
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
            ),
          ],
        ),
      ],
    ),
  );
}