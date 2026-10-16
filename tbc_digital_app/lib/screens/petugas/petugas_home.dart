import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tbc_digital_app/services/api_service_petugas.dart';
import '../../services/fcm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tbc_digital_app/chat/drag_bubble_chart_button.dart';
import 'package:tbc_digital_app/components/chat/draggable_chat_button.dart';

class DashboardPetugas extends StatefulWidget {
  const DashboardPetugas({super.key});

  @override
  State<DashboardPetugas> createState() => _DashboardPetugasState();
}

class _DashboardPetugasState extends State<DashboardPetugas> {
  String selectedDesa = "Semua Desa";
  bool isLoading = true;
  Map<String, dynamic>? apiData;
  Map<String, dynamic>? petugas;
  List<Map<String, dynamic>> villages = [];

  final fcm = FCMService();

  @override
  void initState() {
    super.initState();
    fetchVillages().then((_) {
      fetchData();
    });

    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");

    if (userString == null) {
      setState(() {
        petugas = {};
      });
      return;
    }

    final data = jsonDecode(userString);

    setState(() {
      petugas = data["petugas"] ?? {};
      fcm.initFCM(data['id']);
    });
  }

  Future<List<Map<String, dynamic>>> fetchPatientsByStatus(
    String status,
  ) async {
    final response = await ApiServicePetugas.getPatientsByStatus(status);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    int? villageId;

    if (selectedDesa != "Semua Desa") {
      final selectedVillage = villages.firstWhere(
        (v) => v['name'] == selectedDesa,
        orElse: () => {},
      );

      villageId = selectedVillage['id'];
    }

    try {
      final res = await ApiServicePetugas.getDashboardPetugas(
        villageId: villageId,
      );

      setState(() {
        apiData = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("ERROR: $e");
    }
  }

  void changeDesa(String value) {
    setState(() {
      selectedDesa = value;
    });

    fetchData();
  }

  Future<void> fetchVillages() async {
    final res = await ApiServicePetugas.getVillages();

    setState(() {
      villages = List<Map<String, dynamic>>.from(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || apiData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = apiData!['summary'];
    final gizi = apiData!['gizi'];
    final umur = apiData!['umur'];

    // int totalGizi = gizi["normal"] + gizi["kurus"] + gizi["sangat"];

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      /// 🔥 WRAP BODY SAJA (TIDAK MERUBAH UI)
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchData();
        },

        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
                child: Column(
                  children: [
                    header(),
                    const SizedBox(height: 20),

                    /// 🔽 FILTER DESA
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButton<String>(
                        value: selectedDesa,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: "Semua Desa",
                            child: Text("Semua Desa"),
                          ),

                          ...villages.map((v) {
                            return DropdownMenuItem(
                              value: v['name'],
                              child: Text(v['name']),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          if (value != null) changeDesa(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TOTAL PASIEN
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7FB77E), Color(0xFF9ED69E)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Pasien",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "${apiData!['total_pasien']} Orang",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STATUS
                    Row(
                      children: [
                        buildCard(
                          "Patuh",
                          data["patuh"],
                          Colors.green,
                          onTap: () {
                            showPatientsByStatus(
                              context,
                              "PATUH",
                              Colors.green,
                            );
                          },
                        ),

                        buildCard(
                          "Terlambat",
                          data["terlambat"],
                          Colors.orange,
                          onTap: () {
                            showPatientsByStatus(
                              context,
                              "TERLAMBAT",
                              Colors.orange,
                            );
                          },
                        ),

                        buildCard(
                          "Tidak",
                          data["tidak"],
                          Colors.red,
                          onTap: () {
                            showPatientsByStatus(context, "TIDAK PATUH", Colors.red);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// BAR CHART
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(show: false),
                                barGroups: [
                                  makeBar(0, data["patuh"], Colors.green),
                                  makeBar(1, data["terlambat"], Colors.orange),
                                  makeBar(2, data["tidak"], Colors.red),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildLegend("Patuh", data["patuh"], Colors.green),

                              buildLegend(
                                "Terlambat",
                                data["terlambat"],
                                Colors.orange,
                              ),

                              buildLegend("Tidak", data["tidak"], Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// GIZI
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Status Gizi Pasien",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "8 Orang",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  // 🔴 GIZI
                                  PieChartSectionData(
                                    value: (gizi["giziBuruk"] ?? 0).toDouble(),
                                    color: Colors.red.shade800,
                                    title: "${gizi["giziBuruk"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["giziKurang"] ?? 0).toDouble(),
                                    color: Colors.orange.shade700,
                                    title: "${gizi["giziKurang"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["normal"] ?? 0).toDouble(),
                                    color: Colors.green.shade700,
                                    title: "${gizi["normal"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["giziLebih"] ?? 0).toDouble(),
                                    color: Colors.blue.shade700,
                                    title: "${gizi["giziLebih"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["obesitas"] ?? 0).toDouble(),
                                    color: Colors.indigo,
                                    title: "${gizi["obesitas"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["obesitas1"] ?? 0).toDouble(),
                                    color: Colors.purple,
                                    title: "${gizi["obesitas1"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["obesitas2"] ?? 0).toDouble(),
                                    color: Colors.black,
                                    title: "${gizi["obesitas2"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),

                                  // 🔵 BERAT BADAN
                                  PieChartSectionData(
                                    value: (gizi["beratBadankurang"] ?? 0)
                                        .toDouble(),
                                    color: Colors.orange,
                                    title: "${gizi["beratBadankurang"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["beratBadanNormal"] ?? 0)
                                        .toDouble(),
                                    color: Colors.green,
                                    title: "${gizi["beratBadanNormal"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: (gizi["beratBadanLebih"] ?? 0)
                                        .toDouble(),
                                    color: Colors.blue,
                                    title: "${gizi["beratBadanLebih"] ?? 0}",
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          GridView.count(
                            crossAxisCount: 3, // ⬅️ ini kuncinya (1 baris = 3)
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3, // biar tidak terlalu tinggi
                            children: [
                              legend("BB Kurang", Colors.orange),
                              legend("BB Normal", Colors.green),
                              legend("BB Lebih", Colors.blue),

                              legend("Gizi Buruk", Colors.red.shade800),
                              legend("Gizi Kurang", Colors.orange.shade700),
                              legend("Normal", Colors.green.shade700),

                              legend("Gizi Lebih", Colors.blue.shade700),
                              legend("Obesitas", Colors.indigo),
                              legend("Obesitas I", Colors.purple),

                              legend("Obesitas II", Colors.black),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👨‍👩‍👧 KATEGORI UMUR (TIDAK DIUBAH)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kategori Umur Pasien",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(show: false),
                                barGroups: [
                                  makeBar(0, umur["balita"]!, Colors.blue),
                                  makeBar(1, umur["remaja"]!, Colors.purple),
                                  makeBar(2, umur["dewasa"]!, Colors.teal),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              legend("Balita", Colors.blue),
                              legend("Remaja", Colors.purple),
                              legend("Dewasa", Colors.teal),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const DraggableChatButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showPatientsByStatus(
    BuildContext context,
    String status,
    Color color,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchPatientsByStatus(status),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 300,
                child: Center(child: Text("Tidak ada pasien")),
              );
            }

            final patients = snapshot.data!;

            return Container(
              padding: const EdgeInsets.all(20),
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pasien $status",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color,
                            child: Text(patient['name'][0]),
                          ),

                          title: Text(patient['name']),

                          subtitle: Text(patient['village'] ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildCard(
    String title,
    int value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color)),

              Text(
                "$value",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeBar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y.toDouble(), color: color, width: 16)],
    );
  }
}

Widget legend(String text, Color color) {
  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12)),
    ],
  );
}

Widget buildLegend(String title, dynamic value, Color color) {
  return Column(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      const SizedBox(height: 6),

      Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      const SizedBox(height: 4),

      Text(
        value.toString(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget header() {
  return Row(
    children: const [
      Expanded(
        child: Text(
          "Dashboard Petugas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Icon(Icons.notifications_none),
      SizedBox(width: 10),
      CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(
          "https://cdn-icons-png.flaticon.com/512/149/149071.png",
        ),
      ),
    ],
  );
}
