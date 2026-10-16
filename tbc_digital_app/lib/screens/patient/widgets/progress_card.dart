import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int current;
  final int total;

  const ProgressCard({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {


    bool isLanjutan = current > 56;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          /// ================= MAIN CONTENT =================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Progress Pengobatan",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "$current / $total Hari",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: current / total,
                backgroundColor: Colors.white30,
                color: Colors.white,
              ),
            ],
          ),

          /// ================= BADGE POJOK KANAN ATAS =================
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLanjutan
                    ? Colors.orange
                    : Colors.red, // 🔥 ubah di sini
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLanjutan ? Colors.orange : Colors.red,
                ),
              ),
              child: Text(
                isLanjutan ? "Fase Lanjutan" : "Fase Awal",
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
}
