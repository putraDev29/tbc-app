import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KontrolScreen extends StatefulWidget {
  const KontrolScreen({super.key});

  @override
  State<KontrolScreen> createState() => _KontrolScreenState();
}

class _KontrolScreenState extends State<KontrolScreen> {
  bool isLoading = true;

  String? startDate;
  String? endDate;

  List<Map<String, dynamic>> jadwal = [];

  @override
  void initState() {
    super.initState();
    loadLocalData();
  }

  /// ================= LOAD LOCAL =================
  Future<void> loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    startDate = prefs.getString("start_date");
    endDate = prefs.getString("end_date");

    /// 🔥 DEBUG (kalau error gampang ketemu)
    print("START: $startDate");
    print("END: $endDate");

    if (startDate != null &&
        startDate!.isNotEmpty &&
        endDate != null &&
        endDate!.isNotEmpty) {
      jadwal = generateSchedule(
        startDate: startDate!,
        endDate: endDate!,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// ================= SAFE PARSE =================
  DateTime safeParse(String? date) {
    try {
      if (date == null || date.isEmpty) {
        return DateTime.now();
      }
      return DateTime.parse(date);
    } catch (e) {
      print("❌ FORMAT ERROR: $date");
      return DateTime.now();
    }
  }

  /// ================= WEEKEND =================
  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  /// ================= SHIFT KE WEEKDAY =================
  DateTime adjustToWeekday(DateTime date) {
    while (isWeekend(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  /// ================= GENERATE SCHEDULE =================
  List<Map<String, dynamic>> generateSchedule({
    required String startDate,
    required String endDate,
  }) {
    DateTime start = safeParse(startDate);
    DateTime end = safeParse(endDate);

    List<Map<String, dynamic>> result = [];
    int index = 1;

    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      DateTime original = current;
      DateTime adjusted = adjustToWeekday(current);

      result.add({
        "title": "Kontrol $index",
        "date": adjusted,
        "date_str":
            "${adjusted.day}/${adjusted.month}/${adjusted.year}",
      });

      current = original.add(const Duration(days: 14));
      index++;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (startDate == null ||
        endDate == null ||
        startDate!.isEmpty ||
        endDate!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Data jadwal belum tersedia"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Jadwal Kontrol",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7FB77E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 80,
          ),
          itemCount: jadwal.length,
          itemBuilder: (context, index) {
            final item = jadwal[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(item['date_str']),
                      const Text(
                        "Kontrol pengambilan obat",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}