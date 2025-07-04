import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SharedDashboardHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onToggleMenu;

  const SharedDashboardHeader({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: const CircleAvatar(
              backgroundImage: AssetImage('images/avatar.png'),
              radius: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(userName, style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
          const Spacer(),
          GestureDetector(
            onTap: onToggleMenu,
            child: const Icon(FontAwesomeIcons.barsStaggered, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
