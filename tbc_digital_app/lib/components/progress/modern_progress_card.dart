import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

Widget modernProgressCard(int current, int total) {
  double progress = (current / total).clamp(0, 1);

  bool isLanjutan = current > 56;

  String fase = isLanjutan ? "Fase Lanjutan" : "Fase Awal";

  Color faseColor = isLanjutan ? Colors.orange : Colors.red;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          const Color(0xFF7FB77E),
          const Color(0xFF9ED69E), // 🔥 base
          AppColors.primary,
          AppColors.primaryLight,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        /// ================= MAIN =================
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Progress Pengobatan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                /// PERSEN
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// HARI
            Text(
              "$current / $total Hari",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            /// PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),

        /// ================= BADGE =================
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: faseColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fase,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
