import 'package:flutter/material.dart';

class BmiTrendCard extends StatelessWidget {
  final List<double> data;
  final int age;

  const BmiTrendCard({
    super.key,
    required this.data,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    double bmi = data.last;

    String status = getStatusGizi(bmi, age);
    Color color = getStatusGiziColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_heart, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Status Gizi: $status",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= STATUS GIZI =================

  String getStatusGizi(double bmi, int age) {
    if (age >= 5 && age <= 18) {
      return getStatusGiziAnak(bmi, age);
    } else {
      return getStatusGiziDewasa(bmi);
    }
  }

  /// DEWASA
  String getStatusGiziDewasa(double bmi) {
    if (bmi < 18.5) {
      return "Berat badan kurang";
    } else if (bmi < 23) {
      return "Normal";
    } else if (bmi < 25) {
      return "Overweight";
    } else if (bmi < 30) {
      return "Obesitas I";
    } else {
      return "Obesitas II";
    }
  }

  /// ANAK
  String getStatusGiziAnak(double bmi, int age) {
    double z = bmi / age;

    if (z >= -3 && z < -2) {
      return "Gizi Kurang";
    } else if (z >= -2 && z <= 1) {
      return "Normal";
    } else if (z > 1 && z <= 2) {
      return "Gizi Lebih";
    } else if (z > 2) {
      return "Obesitas";
    } else {
      return "Gizi Buruk";
    }
  }

  /// COLOR MAPPING
  Color getStatusGiziColor(String status) {
    switch (status) {
      case "Normal":
        return Colors.green;

      case "Berat badan kurang":
      case "Gizi Kurang":
      case "Gizi Buruk":
        return Colors.orange;

      case "Overweight":
      case "Gizi Lebih":
        return Colors.deepOrange;

      case "Obesitas I":
      case "Obesitas II":
      case "Obesitas":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}