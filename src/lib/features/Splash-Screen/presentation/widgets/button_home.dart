import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonHome extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const ButtonHome({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 30),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 25)),
    );
  }
}
