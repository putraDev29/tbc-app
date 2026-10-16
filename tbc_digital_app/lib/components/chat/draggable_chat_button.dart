import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../screens/chat/chat_list_petugas.dart';
import '../../screens/chat/chat_pasien_screen.dart';

class DraggableChatButton extends StatefulWidget {
  const DraggableChatButton({super.key});

  @override
  State<DraggableChatButton> createState() => _DraggableChatButtonState();
}

class _DraggableChatButtonState extends State<DraggableChatButton> {
  Offset? position;
  String role = "";
  String userId = "";
  bool isHidden = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(AppConstants.keyUser);

    if (userString == null) return;

    final user = jsonDecode(userString);
    if (!mounted) return;

    setState(() {
      role = user['role']?.toString() ?? '';
      userId = user['id']?.toString() ?? '';
    });
  }

  void openChat() {
    if (role == AppConstants.rolePasien) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatScreenPasien(receiverId: "2"),
        ),
      );
    } else if (role == AppConstants.rolePetugas) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChatListPetugas(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return const SizedBox();
    }

    final screenSize = MediaQuery.of(context).size;

    /// posisi default pojok kanan bawah
    position ??= Offset(
      screenSize.width - 80,
      screenSize.height - 280,
    );

    return Positioned(
      left: position!.dx,
      top: position!.dy,
      child: Draggable(
        feedback: _buildButton(),
        childWhenDragging: const SizedBox(),
        onDragEnd: (details) {
          double dx = details.offset.dx;
          double dy = details.offset.dy;

          /// batas layar
          if (dx < 0) dx = 0;
          if (dy < 0) dy = 0;

          if (dx > screenSize.width - 70) {
            dx = screenSize.width - 70;
          }

          if (dy > screenSize.height - 140) {
            dy = screenSize.height - 140;
          }

          setState(() {
            position = Offset(dx, dy);
          });
        },
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: openChat,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                )
              ],
            ),
            child: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
          ),
        ),

        /// tombol close
        Positioned(
          right: -5,
          top: -5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isHidden = true;
              });
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

