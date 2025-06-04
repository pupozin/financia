import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Text('Chart Screen', style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }
}
