import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tbc_digital_app/screens/login_screen.dart';
import 'package:tbc_digital_app/screens/patient/edukasi_screen.dart';
import 'package:tbc_digital_app/screens/patient/kontrol_screen.dart';
import 'package:tbc_digital_app/screens/patient/patient_home.dart';
import 'package:tbc_digital_app/screens/patient/profile_screen.dart';

import 'package:tbc_digital_app/screens/petugas/petugas_home.dart';
import 'package:tbc_digital_app/screens/petugas/patient/list_pasien.dart';
import 'package:tbc_digital_app/screens/petugas/validasi_pasien.dart';
import 'package:tbc_digital_app/screens/petugas/profile_screen.dart';

import 'package:tbc_digital_app/screens/kapus/kapus_home.dart';
import 'package:tbc_digital_app/screens/kapus/profile_screen.dart';
import 'package:tbc_digital_app/components/navigation/main_navigation.dart';
import 'package:tbc_digital_app/components/navigation/main_navigation_kapus.dart';
import 'package:tbc_digital_app/components/navigation/main_navigation_petugas.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();

  Timer? _timer;
  VideoPlayerController? _videoController;
  VoidCallback? _videoListener;

  int currentIndex = 0;
  int activeVideoIndex = -1;

  bool isUserInteracting = false;
  bool videoCompleted = false;
  bool isVideoPaused = false;

  bool isLoggedIn = false;
  String? role;

  final List<Map<String, String>> data = [
    {"video": "assets/videos/video1.mp4"},
    {"video": "assets/videos/video2.mp4"},
    {"image": "assets/images/img1.jpeg"},
    {"image": "assets/images/img2.jpeg"},
    {"image": "assets/images/img3.jpeg"},
    {"image": "assets/images/img4.jpeg"},
    {"image": "assets/images/img5.jpeg"},
    {"image": "assets/images/img6.jpeg"},
    {"image": "assets/images/img7.jpeg"},
    {"image": "assets/images/img8.jpeg"},
    {"image": "assets/images/img9.jpeg"},
  ];

  @override
  void initState() {
    super.initState();

    checkLoginSilent(); // hanya ambil status login

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMedia(0);
    });
  }

  // 🔥 CEK LOGIN TANPA NAVIGASI
  Future<void> checkLoginSilent() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    role = prefs.getString("role");

    isLoggedIn = token != null;

    if (token != null) {
      handleNext();
    }
  }

  // 🔥 ROUTING FINAL SETELAH SPLASH / SKIP
  void handleNext() {
    if (isLoggedIn) {
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
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void disposeVideo() {
    if (_videoController != null && _videoListener != null) {
      _videoController!.removeListener(_videoListener!);
    }
    _videoController?.dispose();
    _videoController = null;
    _videoListener = null;
  }

  void loadMedia(int index) {
    final item = data[index];

    _timer?.cancel();
    disposeVideo();

    videoCompleted = false;
    isVideoPaused = false;
    activeVideoIndex = index;

    if (item["video"] != null) {
      final controller = VideoPlayerController.asset(item["video"]!);
      _videoController = controller;

      controller.initialize().then((_) {
        if (!mounted || activeVideoIndex != index) return;

        controller.play();
        setState(() {});

        _videoListener = () {
          if (!mounted || activeVideoIndex != index) return;

          final v = controller.value;

          if (v.isInitialized &&
              v.isCompleted &&
              !videoCompleted &&
              !isUserInteracting &&
              !isVideoPaused) {
            videoCompleted = true;
            goNext();
          }
        };

        controller.addListener(_videoListener!);
      });
    } else {
      startAutoSlide();
    }
  }

  void goNext() {
    if (currentIndex < data.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }

    _controller.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void startAutoSlide() {
    _timer = Timer(const Duration(seconds: 4), () {
      if (!isUserInteracting) goNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    disposeVideo();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanDown: (_) {
          isUserInteracting = true;
          _timer?.cancel();
          _videoController?.pause();
        },
        onPanEnd: (_) => isUserInteracting = false,
        onPanCancel: () => isUserInteracting = false,

        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: data.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
                loadMedia(index);
              },
              itemBuilder: (context, index) {
                final item = data[index];

                if (item["video"] != null &&
                    index == activeVideoIndex &&
                    _videoController != null &&
                    _videoController!.value.isInitialized) {
                  return GestureDetector(
                    onTap: () {
                      final controller = _videoController!;
                      if (controller.value.isPlaying) {
                        controller.pause();
                        isVideoPaused = true;
                      } else {
                        controller.play();
                        isVideoPaused = false;
                      }
                      setState(() {});
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        ),
                        if (isVideoPaused)
                          const Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Image.asset(
                          item["image"] ?? "assets/images/img1.jpeg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        item["image"] ?? "assets/images/img1.jpeg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                );
              },
            ),

            // SKIP BUTTON
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: handleNext,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "Skip Untuk Login",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // DOT INDICATOR
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(data.length, (index) {
                  final isActive = index == currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
