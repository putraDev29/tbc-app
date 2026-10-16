import 'package:flutter/material.dart';
import 'package:tbc_digital_app/components/common/section_title.dart';
import 'package:tbc_digital_app/components/common/modern_title.dart';
import 'package:tbc_digital_app/components/progress/modern_progress_card.dart';

class DetailPasienScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;

  const DetailPasienScreen({super.key, required this.pasien});

  @override
  State<DetailPasienScreen> createState() => _DetailPasienScreenState();
}

class _DetailPasienScreenState extends State<DetailPasienScreen> {
  Color statusColor(String status) {
    switch (status) {
      case "PATUH":
        return Colors.green;
      case "TERLAMBAT":
        return Colors.orange;
      case "TIDAK":
      case "TIDAK PATUH":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case "PATUH":
        return Icons.check_circle;
      case "TERLAMBAT":
        return Icons.access_time;
      case "TIDAK":
      case "TIDAK PATUH":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String getLatestStatus(List history) {
    if (history.isEmpty) return "-";
    return history[0]["status"] ?? "-";
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minHeight: 28), // 🔥 jaga tinggi stabil
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 1, // 🔥 kunci center vertikal
        ),
      ),
    );
  }

  Widget statusPengobatanBadge(String status) {
    final isAktif = status == "aktif";
    final color = isAktif ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = (widget.pasien["history"] ?? []) as List;

    final health = (widget.pasien["health"] ?? []) as List;
    health.sort((a, b) => b["date"].compareTo(a["date"]));

    final latestHealth = health.isNotEmpty ? health.first : null;

    final weight = latestHealth?["weight"] ?? "-";
    final height = latestHealth?["height"] ?? "-";
    final bmi = latestHealth?["bmi"] ?? "-";
    final statusGizi = latestHealth?["status_gizi"] ?? "-";

    final progress = widget.pasien["progress"] as Map<String, dynamic>?;
    final totalDay = progress?["total_days"] ?? 0;
    final currentDay = progress?["current_day"] ?? 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FB),

        appBar: AppBar(
          title: const Text(
            "Data Pasien",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, // 🔥 text putih
            ),
          ),
          backgroundColor: const Color(
            0xFF7FB77E,
          ), // 🔥 sage lebih hijau & fresh
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // 🔥 icon ikut putih
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFF7FB77E),
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),

            const SizedBox(height: 10),

            Text(
              widget.pasien["nama"] ?? "-",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TabBar(
                labelColor: Color(0xFF7FB77E),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF7FB77E),
                tabs: [
                  Tab(text: "Detail"),
                  Tab(text: "Pengobatan"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                children: [
                  /// ================= DETAIL =================
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      sectionTitle("Informasi Pasien"),

                      modernTitle(Icons.person, "Nama", widget.pasien["nama"]),
                      modernTitle(
                        Icons.cake,
                        "Umur",
                        "${widget.pasien["umur"]} tahun",
                      ),
                      modernTitle(
                        Icons.location_on,
                        "Alamat",
                        widget.pasien["alamat"],
                      ),
                      modernTitle(Icons.monitor_weight, "BB", "$weight kg"),
                      modernTitle(Icons.height, "TB", "$height cm"),
                      modernTitle(Icons.fitness_center, "BMI", "$bmi"),
                      modernTitle(
                        Icons.health_and_safety,
                        "Status Gizi",
                        statusGizi,
                      ),

                      const SizedBox(height: 16),
                      sectionTitle("Status Pengobatan"),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            /// ================= DURASI =================
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: Color(0xFF7FB77E),
                                ),
                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text("Durasi Pengobatan"),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF7FB77E).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    totalDay?.toString() ?? "-",
                                    style: const TextStyle(
                                      color: Color(0xFF7FB77E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade300, height: 1),
                            const SizedBox(height: 12),

                            /// ================= STATUS =================
                            Row(
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  color: Color(0xFF7FB77E),
                                ),
                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text("Status Pengobatan"),
                                ),

                                statusPengobatanBadge(
                                  widget.pasien["status_pengobatan"] ?? "aktif",
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            /// ================= PROGRESS =================
                            modernProgressCard(currentDay, totalDay),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ================= PERIODE =================
                      sectionTitle("Periode"),

                      modernTitle(
                        Icons.play_arrow,
                        "Mulai",
                        widget.pasien["mulai"],
                      ),
                      modernTitle(Icons.flag, "Akhir", widget.pasien["akhir"]),
                    ],
                  ),

                  /// ================= HISTORY =================
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final h = history[index];
                      final status = h["status"];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              statusIcon(status),
                              color: statusColor(status),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h["tanggal"] ?? "-",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  /// 🔥 HARI KE-
                                  Text(
                                    "Hari ke-${hitungHariDariTanggal(
                                      widget.pasien["mulai"], // 🔥 tanggal mulai manual
                                      h["tanggal"] ?? "",
                                    )}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            statusBadge(status),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int hitungHariDariTanggal(String mulai, String tanggal) {
    try {
      final start = DateTime.parse(mulai); // YYYY-MM-DD
      final current = DateTime.parse(tanggal);

      final diff = current.difference(start).inDays + 1;

      if (diff < 1) return 1;
      return diff;
    } catch (e) {
      return 0;
    }
  }
}
