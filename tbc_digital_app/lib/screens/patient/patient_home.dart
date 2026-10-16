import 'package:flutter/material.dart';
import 'package:tbc_digital_app/screens/patient/upload_bukti.dart';
import 'package:tbc_digital_app/screens/patient/widgets/adherence_card.dart';
import 'package:tbc_digital_app/screens/patient/widgets/bmi_trend_card.dart';
import 'package:tbc_digital_app/screens/patient/widgets/health_card.dart';
import 'package:tbc_digital_app/screens/patient/widgets/start_card.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/fcm_service.dart';
import 'dart:convert';

// 🔥 IMPORT WIDGET
import 'package:tbc_digital_app/screens/patient/widgets/header_widget.dart';
import 'package:tbc_digital_app/screens/patient/widgets/greeting_widget.dart';
import 'package:tbc_digital_app/screens/patient/widgets/daily_status_card.dart';
import 'package:tbc_digital_app/screens/patient/widgets/point_card.dart';
import 'package:tbc_digital_app/screens/patient/widgets/progress_card.dart';
import 'package:tbc_digital_app/chat/drag_bubble_chart_button.dart';
import 'package:tbc_digital_app/components/chat/draggable_chat_button.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  DashboardModel? data;
  bool isLoading = true;
  int? patientId;

  final fcm = FCMService();

  String filter = "MINGGU";

  @override
  void initState() {
    super.initState();
    loadPatientId();
  }

  Future<void> loadPatientId() async {
    final prefs = await SharedPreferences.getInstance();

    int? id = prefs.getInt("patient_id");
    int? idUser = prefs.getInt("user_id");

    if (id == null) return;
    if (idUser == null) return;

    setState(() {
      patientId = id;
      fcm.initFCM(idUser);
    });

    loadData();
  }

  Future<void> loadData() async {
    if (patientId == null) return;

    try {
      final res = await ApiService.getDashboard(patientId!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("start_date", res.progress.startDate);
      await prefs.setString("end_date", res.progress.endDate);
      await prefs.setString("data", jsonEncode(res.toJson()));

      setState(() {
        data = res;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final d = data!;

    List<double> bmi = filter == "MINGGU"
        ? d.health.week.map((e) => e.bmi).toList()
        : d.health.month.map((e) => e.bmi).toList();

    List<double> bb = filter == "MINGGU"
        ? d.health.week.map((e) => e.weight).toList()
        : d.health.month.map((e) => e.weight).toList();

    List<double> tb = filter == "MINGGU"
        ? d.health.week.map((e) => e.height).toList()
        : d.health.month.map((e) => e.height).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await loadData();
              },

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(), // ✅ FIX PENTING
                padding: const EdgeInsets.all(16),
                children: [
                  const HeaderWidget(),
                  const SizedBox(height: 20),

                  GreetingWidget(name: d.patient.name),
                  const SizedBox(height: 20),

                  DailyStatusCard(
                    status: d.todayStatus,
                    onUpload: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UploadBuktiPage()),
                      );

                      if (result == true) loadData();
                    },
                  ),

                  const SizedBox(height: 20),

                  PointCard(
                    total: d.points.totalPoint,
                    max: d.points.maxPoint,
                    percent: d.points.percent,
                    status: d.points.status,
                    color: getStatusColor(d.points.status),
                    icon: getStatusIcon(d.points.status),
                  ),

                  const SizedBox(height: 20),

                  ProgressCard(
                    current: d.progress.currentDay,
                    total: d.progress.totalDays,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: StatCard("Patuh", d.adherence.patuh, Colors.green),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          "Terlambat",
                          d.adherence.terlambat,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard("Tidak", d.adherence.tidak, Colors.red),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  AdherenceChart(
                    patuh: d.adherence.patuh,
                    terlambat: d.adherence.terlambat,
                    tidak: d.adherence.tidak,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("1 Minggu"),
                        selected: filter == "MINGGU",
                        onSelected: (_) => setState(() => filter = "MINGGU"),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("1 Bulan"),
                        selected: filter == "BULAN",
                        onSelected: (_) => setState(() => filter = "BULAN"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  HealthChart(bmi: bmi, bb: bb, tb: tb),

                  const SizedBox(height: 20),

                  BmiTrendCard(
                    data: bmi,
                    age: data!.patient.age,
                  ),
                ],
              ),
            ),

            DraggableChatButton(),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "PATUH":
        return Colors.green;
      case "TERLAMBAT":
        return Colors.orange;
      case "TIDAK PATUH":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "PATUH":
        return Icons.check_circle;
      case "TERLAMBAT":
        return Icons.access_time;
      case "TIDAK PATUH":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}