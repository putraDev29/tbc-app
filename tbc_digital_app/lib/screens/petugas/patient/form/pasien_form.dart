import 'package:flutter/material.dart';
import '../../../../components/inputs/modern_input.dart';
import '../../../../components/inputs/modern_dropdown.dart';
import '../../../../components/inputs/modern_date_field.dart';
import '../../../../components/inputs/modern_data_field.dart';
import '../../../../services/api_service_petugas.dart';

void showFormTambah(
  BuildContext context, {
  Map<String, dynamic>? pasien,
  Function()? onSuccess,
}) {
  final nikKey = GlobalKey();
  final namaKey = GlobalKey();
  final tglLahirKey = GlobalKey();
  final desaKey = GlobalKey();
  final alamatKey = GlobalKey();
  final tglMulaiKey = GlobalKey();
  final tglAkhirKey = GlobalKey();
  final tbKey = GlobalKey();
  final bbKey = GlobalKey();
  final tbKey2 = GlobalKey();
  final bbKey2 = GlobalKey();
  final formKey = GlobalKey<FormState>();

  final isEdit = pasien != null;

  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final umurController = TextEditingController();
  final statusGiziController = TextEditingController();
  final desaController = TextEditingController();
  final alamatDetailController = TextEditingController();
  final tbController = TextEditingController();
  final bbController = TextEditingController();
  final bmiController = TextEditingController();

  String durasi = "6 Bulan";
  String jeniskelamin = "Laki - laki";
  DateTime? tglLahir;
  DateTime? tglMulai;
  DateTime? tglAkhir;
  int umur = 0;

  /// INIT EDIT
  if (isEdit) {
    nikController.text = pasien["nik"] ?? "";
    namaController.text = pasien["nama"] ?? "";
    umurController.text = pasien["umur"]?.toString() ?? "";
    desaController.text = pasien["desa"] ?? "";
    alamatDetailController.text = pasien["alamat"] ?? "";
    tglLahir = DateTime.tryParse(pasien["tanggal_lahir"] ?? "");
    jeniskelamin = pasien["gender"] ?? "Laki - laki";
    durasi = pasien["treatment_duration"] ?? "6 Bulan";
    umur = int.tryParse(umurController.text) ?? 0;
    tglMulai = DateTime.tryParse(pasien["mulai"] ?? "");
    tglAkhir = DateTime.tryParse(pasien["akhir"] ?? "");
    if (tglMulai != null) {
      tglAkhir = hitungTglAkhir(tglMulai, durasi);
    }

    final health = (pasien["health"] ?? []) as List;

    if (health.isNotEmpty) {
      // 🔥 SORT dari terbaru
      health.sort((a, b) => b["date"].compareTo(a["date"]));

      final latest = health.first;

      tbController.text = latest["height"]?.toString() ?? "";
      bbController.text = latest["weight"]?.toString() ?? "";
      statusGiziController.text = latest["status_gizi"] ?? "";
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // 🔥 penting
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.only(
                top: 80,
              ), // 🔥 jarak dari atas layar
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          isEdit ? "Edit Pasien" : "Tambah Pasien",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// NIK
                        Container(
                          key: nikKey,
                          child: modernInputField(
                            "NIK",
                            nikController,
                            readOnly: isEdit,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Nama
                        Container(
                          key: namaKey,
                          child: modernInputField("Nama", namaController),
                        ),
                        const SizedBox(height: 20),

                        /// Gender
                        modernDropdown(
                          "Jenis Kelamin",
                          jeniskelamin,
                          ["Laki - laki", "Wanita"],
                          (val) => setModalState(() => jeniskelamin = val),
                        ),
                        const SizedBox(height: 20),

                        /// Tgl Lahir
                        modernDateField("Tanggal Lahir", tglLahir, (val) {
                          setModalState(() {
                            tglLahir = val;
                            umur = hitungUmur(val);
                            umurController.text = umur.toString();
                          });
                        }),
                        const SizedBox(height: 20),

                        modernDataField("Umur", umurController.text),
                        const SizedBox(height: 20),

                        Container(
                          key: desaKey,
                          child: modernInputField("Desa", desaController),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          key: alamatKey,
                          child: modernInputField(
                            "Alamat Detail",
                            alamatDetailController,
                          ),
                        ),
                        const SizedBox(height: 20),

                        modernDropdown(
                          "Durasi Pengobatan",
                          durasi,
                          ["6 Bulan", "9 Bulan", "12 Bulan"],
                          (val) {
                            setModalState(() {
                              durasi = val;
                              tglAkhir = hitungTglAkhir(tglMulai, durasi);
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        modernDateField("Mulai Pengobatan", tglMulai, (val) {
                          setModalState(() {
                            tglMulai = val;
                            tglAkhir = hitungTglAkhir(tglMulai, durasi);
                          });
                        }),
                        const SizedBox(height: 20),

                        modernDateField("Akhir Pengobatan", tglAkhir, (val) {
                          setModalState(() {
                            tglAkhir = val;
                          });
                        }),
                        const SizedBox(height: 20),

                        /// 🔥 LOGIC UMUR
                        if (umur >= 5) ...[
                          Container(
                            key: tbKey,
                            child: modernInputField(
                              "Tinggi Badan (cm)",
                              tbController,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            key: bbKey,
                            child: modernInputField(
                              "Berat Badan (kg)",
                              bbController,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (umur < 5) ...[
                          Container(
                            key: tbKey2,
                            child: modernInputField(
                              "Tinggi Badan (cm)",
                              tbController,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            key: bbKey2,
                            child: modernInputField(
                              "Berat Badan (kg)",
                              bbController,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          modernInputField(
                            "BMI",
                            bmiController,
                            required: false,
                          ), // bisa edit manual
                          const SizedBox(height: 20),

                          modernInputField(
                            "Status Gizi",
                            statusGiziController,
                            required: false,
                          ),
                          const SizedBox(height: 20),
                        ],

                        /// 🔥 SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(14),
                              backgroundColor: const Color(0xFF7FB77E),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                // cek manual urutan field
                                if (nikController.text.isEmpty) {
                                  scrollToField(nikKey);
                                  return;
                                }
                                if (namaController.text.isEmpty) {
                                  scrollToField(namaKey);
                                  return;
                                }
                                if (tglLahir == null) {
                                  scrollToField(tglLahirKey);
                                  return;
                                }
                                if (desaController.text.isEmpty) {
                                  scrollToField(desaKey);
                                  return;
                                }
                                if (alamatDetailController.text.isEmpty) {
                                  scrollToField(alamatKey);
                                  return;
                                }
                                if (tglMulai == null) {
                                  scrollToField(tglMulaiKey);
                                  return;
                                }
                                if (tglAkhir == null) {
                                  scrollToField(tglAkhirKey);
                                  return;
                                }

                                return;
                              }

                              final payload = {
                                "nik": nikController.text,
                                "name": namaController.text,
                                "gender": jeniskelamin,
                                "date_born": tglLahir?.toIso8601String(),
                                "age": umur,
                                "village": desaController.text,
                                "address": alamatDetailController.text,
                                "treatment_duration": durasi,
                                "start_date": tglMulai?.toIso8601String(),
                                "end_date": tglAkhir?.toIso8601String(),
                                "height": tbController.text,
                                "weight": bbController.text,
                                "bmi": bmiController.text,
                                "status_gizi": statusGiziController.text,
                              };

                              final success = isEdit
                                  ? await ApiServicePetugas.updatePatient(
                                      pasien["id"],
                                      payload,
                                    )
                                  : await ApiServicePetugas.createPatient(
                                      payload,
                                    );

                              if (success) {
                                Navigator.pop(context);
                                onSuccess?.call();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? "Berhasil update"
                                        : "Berhasil tambah",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: Text(
                              isEdit ? "Update" : "Simpan",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void scrollToField(GlobalKey key) {
  final context = key.currentContext;
  if (context != null) {
    Scrollable.ensureVisible(
      context,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

/// helper tetap
DateTime? hitungTglAkhir(DateTime? mulai, String? durasi) {
  if (mulai == null || durasi == null) return null;

  int bulan = durasi == "6 Bulan"
      ? 6
      : durasi == "9 Bulan"
      ? 9
      : 12;

  /// 🔥 1 bulan = 28 hari
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
