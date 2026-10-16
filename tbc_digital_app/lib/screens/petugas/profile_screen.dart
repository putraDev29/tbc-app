import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tbc_digital_app/constants/constants.dart';
import 'package:tbc_digital_app/screens/login_screen.dart';
import 'package:tbc_digital_app/services/local_notification_service.dart';

class ProfilePetugasScreen extends StatefulWidget {
  const ProfilePetugasScreen({super.key});

  @override
  State<ProfilePetugasScreen> createState() => _ProfilePetugasScreenState();
}

class _ProfilePetugasScreenState extends State<ProfilePetugasScreen> {
  Map<String, dynamic>? petugas;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// 🔥 LOAD USER LOGIN
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
    });
  }

  /// 🔥 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      print("Error FCM logout: $e");
    }

    try {
      await LocalNotificationService.plugin.cancelAll();
    } catch (e) {
      print("Error notif clear: $e");
    }

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// 🔥 STATUS COLOR (TIDAK DIUBAH)
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "aktif":
        return Colors.green;
      case "nonaktif":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 LOADING STATE
    if (petugas == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final statusColor = getStatusColor(petugas!['status'] ?? 'aktif');

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Profil Petugas",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// ================= HEADER =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.badge,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// NAMA
                    Text(
                      petugas!['name'] ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        (petugas!['status'] ?? "-").toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// ================= INFO =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    profileItem(Icons.person, "Nama", petugas!['name'] ?? "-"),
                    const Divider(),

                    profileItem(
                      Icons.cake,
                      "Umur",
                      "${hitungUmur(petugas!['date_born'])} Tahun",
                    ),
                    const Divider(),

                    profileItem(
                      Icons.location_on,
                      "Alamat",
                      petugas!['address'] ?? "-",
                    ),
                    const Divider(),

                    profileItem(
                      Icons.work,
                      "Jabatan",
                      petugas!['jabatan'] ?? "-",
                    ),
                    const Divider(),

                    profileItem(
                      Icons.verified_user,
                      "Status Petugas",
                      petugas!['status'] ?? "-",
                      valueColor: statusColor,
                    ),
                  ],
                ),
              ),

              /// ================= LOGOUT =================
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  onTap: logout,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Keluar",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= ITEM =================
  Widget profileItem(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7FB77E)),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

String hitungUmur(String tanggalLahir) {
  final birthDate = DateTime.parse(tanggalLahir);
  final today = DateTime.now();

  int age = today.year - birthDate.year;

  // koreksi kalau belum ulang tahun tahun ini
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age.toString();
}
