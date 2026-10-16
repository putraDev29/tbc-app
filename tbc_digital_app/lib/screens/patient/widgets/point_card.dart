import 'package:flutter/material.dart';

class PointCard extends StatelessWidget {
  final int total;
  final int max;
  final double percent;
  final String status;
  final Color color;
  final IconData icon;

  const PointCard({
    super.key,
    required this.total,
    required this.max,
    required this.percent,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Poin", style: TextStyle(color: Colors.white70)),
              Text(
                "$total / $max",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("$status", style: const TextStyle(color: Colors.white)),
            ],
          ),
          Icon(icon, color: Colors.white, size: 40),
        ],
      ),
    );
  }
}
