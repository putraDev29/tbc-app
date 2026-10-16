import 'package:flutter/material.dart';

class DailyStatusCard extends StatelessWidget {
  final String status;
  final VoidCallback onUpload;

  const DailyStatusCard({
    super.key,
    required this.status,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    if (status == "BELUM" || now.hour == 0 && now.minute <= 1) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              "Waktunya minum obat 💊",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Minum obat sekarang"),
            ),
          ],
        ),
      );
    }

    if (status == "DITOLAK" && DateTime.now().hour >= 20) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              "Status ditolak, Upload foto lagi",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Minum obat sekarang"),
            ),
          ],
        ),
      );
    }

    /// =====================
    /// STATUS CONFIG
    /// =====================
    final _config = _getStatusConfig(status);

    /// =====================
    /// WAKTUNYA MINUM OBAT
    /// =====================
    if (_config.title == "Waktunya minum obat 💊") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              _config.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _config.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Minum obat sekarang"),
            ),
          ],
        ),
      );
    }

    /// =====================
    /// DEFAULT CARD
    /// =====================
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _config.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _config.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _config.icon,
              color: _config.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _config.title,
                  style: TextStyle(
                    color: _config.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _config.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),

                if (_config.title != "MENUNGGU") ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Status sudah divalidasi petugas",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// CONFIG STATUS MODEL
/// =====================
class _StatusConfig {
  final Color color;
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;

  _StatusConfig({
    required this.color,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// =====================
/// STATUS MAPPING
/// =====================
_StatusConfig _getStatusConfig(String status) {
  final now = DateTime.now();

  // Jam 18:00 - 18:30
  final start = DateTime(now.year, now.month, now.day, 20, 00);
  final end = DateTime(now.year, now.month, now.day, 20, 59);

  final isTime =
      (now.isAtSameMomentAs(start) || now.isAfter(start)) &&
      (now.isBefore(end) || now.isAtSameMomentAs(end));

  // Jika sedang waktunya minum obat
  if (status == "PATUH" && isTime || status == "TERLAMBAT" && isTime || status == "TIDAK PATUH" && isTime) {
    return _StatusConfig(
      color: Colors.red,
      iconBg: Colors.transparent,
      icon: Icons.circle,
      title: "Waktunya minum obat 💊",
      subtitle: "Segera minum obat sekarang 💊",
    );
  }

  // Diluar jam 18:00 - 18:30 tampilkan status normal
  if (status == "PATUH") {
    return _StatusConfig(
      color: Colors.green,
      iconBg: const Color(0xFFC8E6C9),
      icon: Icons.check,
      title: "PATUH",
      subtitle: "Kamu minum obat tepat waktu 👍",
    );
  }

  if (status == "TERLAMBAT") {
    return _StatusConfig(
      color: Colors.orange,
      iconBg: const Color(0xFFFFE0B2),
      icon: Icons.schedule,
      title: "TERLAMBAT",
      subtitle: "Kamu minum obat terlambat ⏰",
    );
  }

  if (status == "TIDAK PATUH") {
    return _StatusConfig(
      color: Colors.red,
      iconBg: const Color(0xFFFFCDD2),
      icon: Icons.close,
      title: "TIDAK PATUH",
      subtitle: "Kamu belum minum obat sesuai jadwal ❌",
    );
  }

  if (status == "MENUNGGU") {
    return _StatusConfig(
      color: Colors.grey,
      iconBg: const Color(0xFFE0E0E0),
      icon: Icons.help,
      title: "MENUNGGU",
      subtitle: "Menunggu Validasi Petugas",
    );
  }

  return _StatusConfig(
    color: Colors.grey,
    iconBg: Colors.transparent,
    icon: Icons.circle,
    title: "-",
    subtitle: "-",
  );
}