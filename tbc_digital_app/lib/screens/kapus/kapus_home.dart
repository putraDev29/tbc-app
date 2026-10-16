import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tbc_digital_app/services/api_service_manajemen.dart';

class KapusHome extends StatefulWidget {
  const KapusHome({super.key});

  @override
  State<KapusHome> createState() => _KapusHomeState();
}

class _KapusHomeState extends State<KapusHome> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Kapus',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF5F7FB)),
      home: const DashboardPage(),
    );
  }
}

/// ================= MODEL =================
class DashboardData {
  final int year;
  final int month;
  final String desa;
  final int kasusAktif;
  final int sembuh;
  final int dropOut;

  DashboardData({
    required this.year,
    required this.month,
    required this.desa,
    required this.kasusAktif,
    required this.sembuh,
    required this.dropOut,
  });
}

class WilayahData {
  final String desa;
  final int aktif;
  final int sembuh;
  final int drop;

  WilayahData({
    required this.desa,
    required this.aktif,
    required this.sembuh,
    required this.drop,
  });
}

/// ================= DASHBOARD =================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> apiData = {};
  bool isLoading = false;

  int selectedYear = 2026;
  int selectedMonth = 0;
  String selectedDesa = "Semua Desa";
  List<String> allDesaList = ["Semua Desa"];

  int selectedIndex = 0;

  final List<String> namaBulan = [
    "Semua Bulan",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  Future<void> loadDesaList() async {
    try {
      final res = await ApiServiceManajemen.fetchDashboard(
        year: selectedYear,
        month: 0, // 🔥 semua bulan
        desa: "Semua Desa", // 🔥 jangan filter desa
      );

      final list = res['wilayah'];

      if (list != null && list is List) {
        final desa = list
            .map<String>((e) => e['desa']?.toString() ?? '')
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList();

        desa.sort();

        setState(() {
          allDesaList = ["Semua Desa", ...desa];
        });
      }
    } catch (e) {
      print("ERROR DESA: $e");
    }
  }

  List<String> get desaList {
    final list = apiData['wilayah'];

    if (list == null || list is! List) {
      return ["Semua Desa"];
    }

    final desa = list
        .map<String>((e) => e['desa']?.toString() ?? '')
        .where((d) => d.isNotEmpty)
        .toSet() // 🔥 hilangkan duplikat
        .toList();

    desa.sort();

    return ["Semua Desa", ...desa];
  }

  @override
  void initState() {
    super.initState();
    loadDesaList();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiServiceManajemen.fetchDashboard(
        year: selectedYear,
        month: selectedMonth,
        desa: selectedDesa,
      );

      setState(() {
        apiData = res; // ✅ langsung assign (karena Map)
      });
    } catch (e) {
      print("ERROR API: $e");
    }

    setState(() => isLoading = false);
  }

  /// ================= SUMMARY =================
  int get totalAktif =>
      int.tryParse(apiData['summary']?['aktif']?.toString() ?? '0') ?? 0;

  int get totalSembuh =>
      int.tryParse(apiData['summary']?['sembuh']?.toString() ?? '0') ?? 0;

  int get totalDrop =>
      int.tryParse(apiData['summary']?['drop']?.toString() ?? '0') ?? 0;

  /// ================= WILAYAH =================
  List<WilayahData> get wilayahData {
    if (apiData['wilayah'] == null) return [];

    return (apiData['wilayah'] as List).map<WilayahData>((e) {
      return WilayahData(
        desa: e['desa'] ?? '',
        aktif: int.tryParse(e['aktif'].toString()) ?? 0,
        sembuh: int.tryParse(e['sembuh'].toString()) ?? 0,
        drop: int.tryParse(e['drop'].toString()) ?? 0,
      );
    }).toList();
  }

  /// ================= CHART =================
  List<DashboardData> get chartData {
    if (apiData['chart'] == null) return [];

    return (apiData['chart'] as List).map<DashboardData>((e) {
      return DashboardData(
        year: selectedYear,
        month: int.tryParse(e['month'].toString()) ?? 0,
        desa: '',
        kasusAktif: int.tryParse(e['aktif'].toString()) ?? 0,
        sembuh: int.tryParse(e['sembuh'].toString()) ?? 0,
        dropOut: int.tryParse(e['drop'].toString()) ?? 0,
      );
    }).toList()..sort((a, b) => a.month.compareTo(b.month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : selectedIndex == 0
            ? SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 80,
                ),
                child: Column(
                  children: [
                    header(),
                    const SizedBox(height: 16),

                    /// FILTER
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration(),
                      child: Column(
                        children: [
                          _filterDropdownYear(),

                          const SizedBox(height: 10),

                          _filterDropdownMonth(),

                          const SizedBox(height: 10),

                          _filterDropdownDesa(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SUMMARY
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: [
                        SummaryCard(
                          "Kasus Aktif",
                          totalAktif.toString(),
                          Colors.orange,
                          Icons.warning,
                        ),
                        SummaryCard(
                          "Kesembuhan",
                          totalSembuh.toString(),
                          Colors.green,
                          Icons.check,
                        ),
                        SummaryCard(
                          "Drop Out",
                          totalDrop.toString(),
                          Colors.red,
                          Icons.close,
                        ),
                        SummaryCard(
                          "Total",
                          (totalAktif + totalSembuh + totalDrop).toString(),
                          Colors.blue,
                          Icons.people,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// LINE CHART
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: cardDecoration(),
                      height: 220,
                      child: chartData.isEmpty
                          ? const Center(child: Text("Tidak ada data"))
                          : LineChart(mainLineChart(chartData)),
                    ),

                    const SizedBox(height: 20),

                    /// BAR CHART
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: cardDecoration(),
                      height: 220,
                      child: wilayahData.isEmpty
                          ? const Center(child: Text("Tidak ada data"))
                          : BarChart(wilayahBarChart(wilayahData)),
                    ),
                  ],
                ),
              )
            : const ProfilePage(),
      ),

      /// NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  List<int> get yearList {
    final currentYear = DateTime.now().year;

    // 🔥 dari 2026 sampai tahun sekarang
    return List.generate(
      currentYear - 2026 + 1,
      (i) => 2026 + i,
    ).reversed.toList(); // opsional: biar terbaru di atas
  }

  /// ================= FILTER =================
  Widget _filterDropdownYear() {
    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: _inputDecoration("Tahun"),
      style: const TextStyle(color: Colors.black),
      dropdownColor: Colors.white,
      items: yearList
          .map(
            (y) => DropdownMenuItem(
              value: y,
              child: Text(
                "Tahun $y",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
          .toList(),
      onChanged: (val) {
        setState(() => selectedYear = val!);
        loadDashboard();
      },
    );
  }

  Widget _filterDropdownMonth() {
    return DropdownButtonFormField<int>(
      value: selectedMonth,
      decoration: _inputDecoration("Bulan"),
      style: const TextStyle(color: Colors.black),
      isExpanded: true,
      menuMaxHeight: 200, // 🔥 hanya tampil sebagian, sisanya scroll
      items: [
        const DropdownMenuItem(
          value: 0,
          child: Text("Semua Bulan", style: TextStyle(color: Colors.black)),
        ),
        ...List.generate(
          12,
          (i) => DropdownMenuItem(
            value: i + 1,
            child: Text(
              namaBulan[i + 1],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
      onChanged: (val) {
        setState(() => selectedMonth = val!);
        loadDashboard();
      },
    );
  }

  Widget _filterDropdownDesa() {
    return DropdownButtonFormField<String>(
      value: selectedDesa,
      decoration: _inputDecoration("Desa"),
      style: const TextStyle(color: Colors.black),
      items: allDesaList
          .map(
            (d) => DropdownMenuItem(
              value: d,
              child: Text(d, style: const TextStyle(color: Colors.black)),
            ),
          )
          .toList(),
      onChanged: (val) {
        setState(() => selectedDesa = val!);
        loadDashboard();
      },
    );
  }

  Widget header() {
    return Row(
      children: const [
        Expanded(
          child: Text(
            "Dashboard Kapus",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
            "https://cdn-icons-png.flaticon.com/512/149/149071.png",
          ),
        ),
      ],
    );
  }
}

/// ================= PROFILE =================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Halaman Profil"));
  }
}

/// ================= COMPONENT =================
InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    hintText: label,
    filled: true,
    fillColor: const Color(0xFFF5F7FB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryCard(this.title, this.value, this.color, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(icon, color: Colors.white, size: 18),
              ),

              const SizedBox(width: 12),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= CHART =================
LineChartData mainLineChart(List<DashboardData> data) {
  return LineChartData(
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: data
            .map((e) => FlSpot(e.month.toDouble(), e.kasusAktif.toDouble()))
            .toList(),
        isCurved: true,
        color: Colors.orange,
      ),
      LineChartBarData(
        spots: data
            .map((e) => FlSpot(e.month.toDouble(), e.sembuh.toDouble()))
            .toList(),
        isCurved: true,
        color: Colors.green,
      ),
      LineChartBarData(
        spots: data
            .map((e) => FlSpot(e.month.toDouble(), e.dropOut.toDouble()))
            .toList(),
        isCurved: true,
        color: Colors.red,
      ),
    ],
  );
}

BarChartData wilayahBarChart(List<WilayahData> data) {
  return BarChartData(
    borderData: FlBorderData(show: false),
    barGroups: List.generate(data.length, (i) {
      final d = data[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: d.aktif.toDouble(), color: Colors.orange),
          BarChartRodData(toY: d.sembuh.toDouble(), color: Colors.green),
          BarChartRodData(toY: d.drop.toDouble(), color: Colors.red),
        ],
      );
    }),
  );
}
