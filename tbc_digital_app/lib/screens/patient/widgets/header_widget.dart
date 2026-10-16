import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            "Dashboard Pasien",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        const SizedBox(width: 2),
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
            "https://cdn-icons-png.flaticon.com/512/149/149071.png",
          ),
        ),
      ],
    );
  }
}