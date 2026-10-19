import 'package:flutter/material.dart';
import 'package:tbc_digital_app/components/loading/shimmer_loading.dart';
import 'package:tbc_digital_app/helper/formatDate.dart';
import 'package:tbc_digital_app/constants/api_constants.dart';
import 'package:tbc_digital_app/constants/app_colors.dart';
import 'package:tbc_digital_app/services/api_service_petugas.dart';
import '../../services/api_constant.dart';
import 'package:tbc_digital_app/utils/date_formatter.dart';

class ValidasiPasienScreen extends StatefulWidget {
  const ValidasiPasienScreen({super.key});

  @override
  State<ValidasiPasienScreen> createState() => _ValidasiPasienScreenState();
}

class _ValidasiPasienScreenState extends State<ValidasiPasienScreen> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  final String baseUrl = ApiConstants.baseUrl;

  Set<int> selectedIds = {};
  bool isMultiSelect = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final result = await ApiServicePetugas.getPending();

    final mapped = result.map<Map<String, dynamic>>((e) {
      final item = e as Map<String, dynamic>;
      String? proofImage = item["proof_image"];

      return {
        "id": item["id"],
        "nama": item["patient"]?["name"] ?? "-",
        "tanggal": item["date"] ?? "-",
        "hari": item["day"] ?? "-",
        "status": mapStatus(item["status_validate"]),
        "foto": (proofImage != null && proofImage.isNotEmpty)
            ? (proofImage.startsWith('http')
                ? proofImage
                : "${ApiConstants.storageUrl}/$proofImage")
            : "",
      };
    }).toList();

    setState(() {
      data = mapped;
      isLoading = false;
    });
  }

  String mapStatus(int? val) {
    switch (val) {
      case 1:
        return "valid";
      case 2:
        return "ditolak";
      default:
        return "pending";
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "valid":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  /// ================= SHOW FOTO =================
  void showFoto(String url, int index) {
    final item = data[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) {
        return Stack(
          children: [
            Center(
              child: (url.isNotEmpty)
                  ? Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/no_image.png",
                          fit: BoxFit.contain,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/no_image.png",
                      fit: BoxFit.contain,
                    ),
            ),

            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          final success = await ApiServicePetugas.reject(
                            item["id"],
                          );

                          if (success) {
                            setState(() {
                              data[index]["status"] = "ditolak";
                            });

                            Navigator.pop(context);
                            fetchData();
                          }
                        },
                        child: const Text(
                          "Tolak",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          final success = await ApiServicePetugas.approve(
                            item["id"],
                          );

                          if (success) {
                            setState(() {
                              data[index]["status"] = "valid";
                            });

                            Navigator.pop(context);
                            fetchData();
                          }
                        },
                        child: const Text(
                          "Setujui",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// ================= BULK POPUP =================
  void _showBulkActionPopup() {
    Future.delayed(Duration.zero, () {
      if (!isMultiSelect || selectedIds.isEmpty) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: const Text("Validasi Massal", textAlign: TextAlign.center),

            content: Text(
              "Total dipilih: ${selectedIds.length} data",
              textAlign: TextAlign.center,
            ),

            actionsAlignment: MainAxisAlignment.center,

            actions: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        for (var id in selectedIds) {
                          await ApiServicePetugas.reject(id);
                        }

                        setState(() {
                          selectedIds.clear();
                          isMultiSelect = false;
                        });

                        Navigator.pop(context);
                        fetchData();
                      },
                      child: const Text(
                        "Tolak Semua",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        for (var id in selectedIds) {
                          await ApiServicePetugas.approve(id);
                        }

                        setState(() {
                          selectedIds.clear();
                          isMultiSelect = false;
                        });

                        Navigator.pop(context);
                        fetchData();
                      },
                      child: const Text(
                        "Setujui Semua",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  /// ================= ITEM =================
  Widget item(Map item, int index) {
    return InkWell(
      onTap: () => showFoto(item["foto"], index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (isMultiSelect)
              Checkbox(
                value: selectedIds.contains(item["id"]),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedIds.add(item["id"]);
                    } else {
                      selectedIds.remove(item["id"]);
                    }
                  });

                  _showBulkActionPopup();
                },
              ),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  (item["foto"] != null && item["foto"].toString().isNotEmpty)
                  ? Image.network(
                      item["foto"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/no_image.png",
                          width: 50,
                          height: 50,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/no_image.png",
                      width: 50,
                      height: 50,
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["nama"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Hari ke ${item["hari"]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    formatDate(item["tanggal"]),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            statusBadge(item["status"]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,

      appBar: AppBar(
        title: const Text(
          "Validasi Pasien",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: Icon(isMultiSelect ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() {
                isMultiSelect = !isMultiSelect;

                if (isMultiSelect) {
                  selectedIds = data.map<int>((e) => e["id"] as int).toSet();
                  _showBulkActionPopup();
                } else {
                  selectedIds.clear();
                }
              });
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: fetchData,
        child: isLoading
            ? ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  120,
                ), // 👈 penting
                itemCount: 12,
                itemBuilder: (_, __) => const ShimmerLoading(),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  120,
                ), // 👈 penting
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return item(data[index], index);
                },
              ),
      ),
    );
  }
}
