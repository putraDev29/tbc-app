import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbc_digital_app/screens/kapus/kapus_home.dart';
import 'package:tbc_digital_app/screens/kapus/profile_screen.dart';
import 'package:tbc_digital_app/screens/patient/edukasi_screen.dart';
import 'package:tbc_digital_app/screens/patient/kontrol_screen.dart';
import 'package:tbc_digital_app/screens/patient/patient_home.dart';
import 'package:tbc_digital_app/screens/patient/profile_screen.dart';
import 'package:tbc_digital_app/screens/petugas/patient/list_pasien.dart';
import 'package:tbc_digital_app/screens/petugas/petugas_home.dart';
import 'package:tbc_digital_app/screens/petugas/profile_screen.dart';
import 'package:tbc_digital_app/screens/petugas/validasi_pasien.dart';
import 'package:http/http.dart' as http;
import 'package:tbc_digital_app/components/navigation/main_navigation.dart';
import 'package:tbc_digital_app/components/navigation/main_navigation_kapus.dart';
import 'package:tbc_digital_app/components/navigation/main_navigation_petugas.dart';
import 'package:tbc_digital_app/screens/register_screen.dart';
import '../constants/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nikController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  /// 🔥 LOGIN SEMENTARA (TANPA API)
  Future<void> login() async {
    if (nikController.text.isEmpty || passwordController.text.isEmpty) {
      showMessage("NIK & Password wajib diisi");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/login"), // emulator
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": nikController.text,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // 🔐 simpan token & role
        await prefs.setString("token", data['token']);
        await prefs.setString("role", data['user']['role']);

        // optional simpan detail user
        await prefs.setString("user", jsonEncode(data['user']));
        await prefs.setString("detail", jsonEncode(data['detail']));

        String role = data['user']['role'];

        if (role == 'pasien') {
          await prefs.setInt("patient_id", data['detail']['id']);
          await prefs.setInt("user_id", data['user']['id']);
        }

        // 🔥 REDIRECT BERDASARKAN ROLE
        if (role == 'pasien') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainNavigation(
                screens: [
                  PatientHome(),
                  EdukasiScreen(),
                  KontrolScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          );
        } else if (role == 'petugas') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainNavigationPetugas(
                screens: [
                  DashboardPetugas(),
                  PasienScreen(),
                  ValidasiPasienScreen(),
                  ProfilePetugasScreen(),
                ],
              ),
            ),
          );
        } else if (role == 'manajemen') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainNavigationKapus(
                screens: [KapusHome(), ProfileKapusScreen()],
              ),
            ),
          );
        }
      } else {
        showMessage(data['message'] ?? "Login gagal");
      }
    } catch (e) {
      print("ERROR: $e");
      showMessage("Error: $e");
    }

    setState(() => isLoading = false);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nikController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7FB77E), // 🔥 base
                  const Color(
                    0xFF9ED69E,
                  ), // 🔥 lebih terang (custom light sage)
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔥 CONTENT
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 400,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo_utama.png',
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.contain,
                            ),

                            /// 🔥 CARD LOGIN
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Masuk",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  /// 🔥 NIK
                                  TextField(
                                    controller: nikController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 16,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "NIK",
                                      hintText: "Masukkan 16 digit NIK",
                                      prefixIcon: const Icon(
                                        Icons.badge_outlined,
                                      ),
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  /// 🔥 PASSWORD
                                  TextField(
                                    controller: passwordController,
                                    obscureText: isObscure,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => isObscure = !isObscure,
                                          );
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  /// 🔥 BUTTON LOGIN
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : login,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              "Login",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  /// 🔥 REGISTER LINK
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Belum punya akun? ",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Daftar Pasien",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
