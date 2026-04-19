import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget wrapForTest(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void configureGoogleFontsForTests() {
  GoogleFonts.config.allowRuntimeFetching = false;
}
