import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadBuktiPage extends StatefulWidget {
  const UploadBuktiPage({Key? key}) : super(key: key);

  @override
  State<UploadBuktiPage> createState() => _UploadBuktiPageState();
}

class _UploadBuktiPageState extends State<UploadBuktiPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

  File? image;
  bool isLoading = false;
  int? patientId;

  @override
  void initState() {
    super.initState();
    initCamera();
    loadPatientId();
  }

  Future<void> loadPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      patientId = prefs.getInt("patient_id");
    });
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.medium);

    await _controller!.initialize();
    if (!mounted) return;

    setState(() {});
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    setState(() {
      image = File(file.path);
    });
  }

  Future<void> submit() async {
    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ambil foto dulu")));
      return;
    }

    if (patientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService.uploadObat(
      patientId!,
      "PATUH",
      image!.path,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berhasil kirim bukti")));

      await Future.delayed(const Duration(seconds: 1));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal kirim")));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bukti Minum Obat",
          style: TextStyle(fontSize: 14), // 🔥 kecilkan di sini
        ),
      ),
      body: Column(
        children: [
          /// CAMERA PREVIEW / FOTO
          Expanded(
            child: image == null
                ? CameraPreview(_controller!)
                : Image.file(image!, fit: BoxFit.cover),
          ),

          const SizedBox(height: 10),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16,
              ), // 🔥 kiri, atas, kanan, bawah
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: takePicture,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Ambil Foto",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Kirim Bukti"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
