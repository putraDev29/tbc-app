import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/components.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final umurController = TextEditingController();
  final phoneController = TextEditingController();
  final desaController = TextEditingController();
  final alamatController = TextEditingController();
  final tbController = TextEditingController();
  final bbController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  String gender = "Laki - laki";
  String durasi = "6 Bulan";

  DateTime? tglLahir;
  DateTime? tglMulai;
  DateTime? tglAkhir;

  int umur = 0;

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      UiHelpers.showSnackBar(
        context,
        "Konfirmasi password tidak sama",
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final payload = {
        "nik": nikController.text,
        "name": namaController.text,
        "gender": gender,
        "date_born": tglLahir?.toIso8601String(),
        "age": umur,
        "village": desaController.text,
        "address": alamatController.text,
        "phone": phoneController.text,
        "treatment_duration": durasi,
        "start_date": tglMulai?.toIso8601String(),
        "end_date": tglAkhir?.toIso8601String(),
        "height": tbController.text,
        "weight": bbController.text,
        "password": passwordController.text,
        "password_confirmation": passwordController.text,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/register-patient"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        UiHelpers.showSnackBar(
          context,
          "Registrasi berhasil. Silakan login.",
          isSuccess: true,
        );

        Navigator.pop(context);
      } else {
        UiHelpers.showSnackBar(
          context,
          data['message'] ?? "Registrasi gagal",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showSnackBar(
        context,
        "Terjadi kesalahan: $e",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nikController.dispose();
    namaController.dispose();
    umurController.dispose();
    desaController.dispose();
    alamatController.dispose();
    phoneController.dispose();
    tbController.dispose();
    bbController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                modernInputField("NIK", nikController, isNumber: true),

                const SizedBox(height: 20),

                modernInputField("Nama", namaController),

                const SizedBox(height: 20),

                modernDropdown(
                  "Jenis Kelamin",
                  gender,
                  ["Laki - laki", "Wanita"],
                  (val) {
                    setState(() {
                      gender = val;
                    });
                  },
                ),

                const SizedBox(height: 20),

                modernDateField("Tanggal Lahir", tglLahir, (val) {
                  setState(() {
                    tglLahir = val;
                    umur = hitungUmur(val);
                    umurController.text = umur.toString();
                  });
                }),

                const SizedBox(height: 20),

                modernDataField("Umur", umurController.text),

                const SizedBox(height: 20),

                modernInputField("Desa", desaController),

                const SizedBox(height: 20),

                modernInputField("Alamat Detail", alamatController),

                const SizedBox(height: 20),

                modernInputField("No HP", phoneController, isNumber: true),

                const SizedBox(height: 20),

                modernDropdown(
                  "Durasi Pengobatan",
                  durasi,
                  ["6 Bulan", "9 Bulan", "12 Bulan"],
                  (val) {
                    setState(() {
                      durasi = val;
                      tglAkhir = hitungTglAkhir(tglMulai, durasi);
                    });
                  },
                ),

                const SizedBox(height: 20),

                modernDateField("Mulai Pengobatan", tglMulai, (val) {
                  setState(() {
                    tglMulai = val;
                    tglAkhir = hitungTglAkhir(tglMulai, durasi);
                  });
                }),

                const SizedBox(height: 20),

                modernDateField("Akhir Pengobatan", tglAkhir, (val) {
                  setState(() {
                    tglAkhir = val;
                  });
                }),

                const SizedBox(height: 20),

                modernInputField(
                  "Tinggi Badan (cm)",
                  tbController,
                  isNumber: true,
                ),

                const SizedBox(height: 20),

                modernInputField(
                  "Berat Badan (kg)",
                  bbController,
                  isNumber: true,
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Daftar",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime? hitungTglAkhir(DateTime? mulai, String? durasi) {
  if (mulai == null || durasi == null) return null;

  int bulan = durasi == "6 Bulan"
      ? 6
      : durasi == "9 Bulan"
      ? 9
      : 12;

  int totalHari = bulan * 28;

  return mulai.add(Duration(days: totalHari));
}

int hitungUmur(DateTime tglLahir) {
  final now = DateTime.now();

  int umur = now.year - tglLahir.year;

  if (now.month < tglLahir.month ||
      (now.month == tglLahir.month && now.day < tglLahir.day)) {
    umur--;
  }

  return umur;
}
