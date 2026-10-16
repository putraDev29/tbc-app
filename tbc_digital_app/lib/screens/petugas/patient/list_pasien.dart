import 'package:flutter/material.dart';
import 'package:tbc_digital_app/components/loading/shimmer_loading.dart';
import 'package:tbc_digital_app/services/api_service_petugas.dart';
import 'widgets/pasien_card.dart';
import 'form/pasien_form.dart';
import 'detail_pasien_screen.dart';

class PasienScreen extends StatefulWidget {
  const PasienScreen({super.key});

  @override
  State<PasienScreen> createState() => _PasienScreenState();
}

class _PasienScreenState extends State<PasienScreen> {
  List<dynamic> pasienList = [];
  bool isLoading = false;
  String search = "";
  bool isLoadingMore = false;
  bool hasMore = true;

  int page = 1;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      page = 1;
      pasienList.clear();
      hasMore = true;
    });

    await fetchMore(); // 🔥 mulai auto load
  }

  Future<void> fetchMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      final res = await ApiServicePetugas.getPatients(page: page);

      final List newData = res['data'] ?? [];
      final meta = res['meta'];

      if (newData.isEmpty) {
        setState(() {
          hasMore = false;
          isLoadingMore = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        pasienList.addAll(newData);
        page++;
        isLoadingMore = false;
      });

      // 🔥 AUTO LANJUT PAGE BERIKUTNYA
      if (meta != null && page <= meta['last_page']) {
        await Future.delayed(const Duration(milliseconds: 200));
        fetchMore();
      } else {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
        isLoading = false;
      });
      print("ERROR FETCH MORE: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = pasienList
        .where(
          (p) => (p["nama"] ?? "").toString().toLowerCase().contains(
            search.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      floatingActionButton: Container(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom + 20, // 🔥 aman dari navbar
        ),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF7FB77E),
          child: const Icon(Icons.add),
          onPressed: () {
            showFormTambah(
              context,
              onSuccess: fetchPatients, // 🔥 refresh setelah simpan
            );
          },
        ),
      ),

      appBar: AppBar(
        title: const Text(
          "Data Pasien",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white, // 🔥 text putih
          ),
        ),
        backgroundColor: const Color(0xFF7FB77E), // 🔥 sage lebih hijau & fresh
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // 🔥 icon ikut putih
      ),

      body: SafeArea(
        child: isLoading
            ? const ShimmerLoading()
            : RefreshIndicator(
                onRefresh: () async {
                  await fetchPatients();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Cari pasien...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => search = val);
                        },
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final pasien = filtered[index];

                          return pasienCard(
                            context,
                            pasien,

                            /// DETAIL
                            () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailPasienScreen(pasien: pasien),
                                ),
                              );

                              if (result == true) fetchPatients();
                            },

                            /// EDIT
                            () => showFormTambah(
                              context,
                              pasien: pasien, // 🔥 WAJIB named parameter
                              onSuccess: fetchPatients, // 🔥 biar auto refresh
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
