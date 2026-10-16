import 'package:flutter/material.dart';
import 'package:tbc_digital_app/services/edukasi_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen>
    with WidgetsBindingObserver {
  final PageController _videoController = PageController();

  final Map<int, VideoPlayerController> _videoPlayers = {};
  final Set<int> _expanded = {};

  int _activeVideoIndex = 0;

  List<Map<String, dynamic>> get data => EdukasiService.edukasi;

  List<Map<String, dynamic>> get articles =>
      data.where((e) => e["type"] == "artikel").toList();

  Map<String, dynamic>? get imageData =>
      data.firstWhere((e) => e["type"] == "image", orElse: () => {});

  Map<String, dynamic>? get videoData =>
      data.firstWhere((e) => e["type"] == "video", orElse: () => {});

  List<String> get images => List<String>.from(imageData?["images"] ?? []);
  List<String> get videos => List<String>.from(videoData?["videos"] ?? []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheVideos();
      _preloadVideos();
    });
  }

  /// ================= PRECACHE =================
  Future<void> _precacheVideos() async {
    for (var path in videos) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {}
    }
  }

  /// ================= PRELOAD =================
  void _preloadVideos() {
    for (int i = 0; i < videos.length && i < 3; i++) {
      _initVideo(i);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _videoPlayers[0]?.play();
    });
  }

  Future<void> _initVideo(int index) async {
    if (index < 0 || index >= videos.length) return;
    if (_videoPlayers[index] != null) return;

    final controller = VideoPlayerController.asset(videos[index]);
    _videoPlayers[index] = controller;

    await controller.initialize();
    controller.setLooping(true);

    if (mounted) setState(() {});
  }

  /// ================= HANDLE VIDEO =================
  void _handleVideoChange(int index) {
    for (var entry in _videoPlayers.entries) {
      entry.value.pause();
    }

    final current = _videoPlayers[index];

    if (current != null && current.value.isInitialized) {
      current.play();
    }

    _initVideo(index + 1);
    _initVideo(index - 1);
  }

  /// ================= NAVIGATION =================
  void _goToPage(int index) {
    if (index < 0 || index >= videos.length) return;

    setState(() {
      _activeVideoIndex = index;
    });

    _videoController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _handleVideoChange(index);
  }

  /// ================= TOGGLE =================
  Future<void> _toggleVideo(int index) async {
    final c = _videoPlayers[index];
    if (c == null) return;

    if (!c.value.isInitialized) {
      await c.initialize();
    }

    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }

    setState(() {});
  }

  void _onVideoPageChanged(int index) {
    setState(() {
      _activeVideoIndex = index;
    });

    _handleVideoChange(index);
  }

  @override
  void dispose() {
    for (final c in _videoPlayers.values) {
      c.dispose();
    }

    _videoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ================= IMAGE =================
  List<String> get remainingImages {
    if (images.length <= 4) return [];
    return images.sublist(4);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edukasi TBC",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF7FB77E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideo(),
            const SizedBox(height: 20),

            ...List.generate(articles.length, (i) {
              List<String> articleImages = [];

              if (i == 0) {
                articleImages = images.take(2).toList();
              } else if (i == 1) {
                articleImages = images.skip(2).take(2).toList();
              }

              return _buildArticle(i, articles[i], articleImages);
            }),

            if (remainingImages.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Edukasi Foto TBC",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: PageView.builder(
                  itemCount: remainingImages.length,
                  itemBuilder: (_, i) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(remainingImages[i], fit: BoxFit.cover),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ),
                        Center(
                          child: Image.asset(
                            remainingImages[i],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ================= VIDEO UI =================
  Widget _buildVideo() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: PageView.builder(
        controller: _videoController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onVideoPageChanged,
        itemCount: videos.length,
        itemBuilder: (_, i) {
          final c = _videoPlayers[i];

          if (c == null || !c.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return GestureDetector(
            onTap: () => _toggleVideo(i),
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// VIDEO
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),

                /// PLAY ICON
                if (!c.value.isPlaying)
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),

                /// PROGRESS
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    c,
                    allowScrubbing: true,
                  ),
                ),

                /// ⬅️ LEFT ARROW
                if (_activeVideoIndex > 0)
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () =>
                            _goToPage(_activeVideoIndex - 1),
                      ),
                    ),
                  ),

                /// ➡️ RIGHT ARROW
                if (_activeVideoIndex < videos.length - 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: () =>
                            _goToPage(_activeVideoIndex + 1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= ARTICLE =================
  Widget _buildArticle(
    int index,
    Map<String, dynamic> article,
    List<String> imgs,
  ) {
    final open = _expanded.contains(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Edukasi Artikel TBC",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        if (imgs.isNotEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: PageView.builder(
              itemCount: imgs.length,
              itemBuilder: (_, i) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imgs[i], fit: BoxFit.cover),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                    Center(child: Image.asset(imgs[i])),
                  ],
                );
              },
            ),
          ),

        InkWell(
          onTap: () {
            setState(() {
              open ? _expanded.remove(index) : _expanded.add(index);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    article["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              article["content"],
              style: const TextStyle(height: 1.6),
            ),
          ),
          crossFadeState: open
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        const SizedBox(height: 10),
        const Divider(),
      ],
    );
  }
}