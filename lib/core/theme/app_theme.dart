import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const rose = Color(0xFFED7FA1);
  static const roseDark = Color(0xFFC95E82);
  static const blush = Color(0xFFFFE4EC);
  static const mint = Color(0xFFDDF4EE);
  static const sky = Color(0xFFDDEEFF);
  static const butter = Color(0xFFFFF0C8);
  static const ink = Color(0xFF453840);
  static const muted = Color(0xFF82737B);
  static const background = Color(0xFFFFFAF7);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(seedColor: rose, surface: background),
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w900,
        color: ink,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
      bodyMedium: TextStyle(color: muted, height: 1.35),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: rose,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0x14C95E82)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: rose, width: 1.5),
      ),
    ),
  );
}

class PastelBackground extends StatelessWidget {
  const PastelBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF8FA), Color(0xFFFFFBF4), Color(0xFFF8FCFB)],
      ),
    ),
    child: Stack(
      children: [
        const Positioned(
          top: -70,
          right: -45,
          child: _PastelOrb(size: 180, color: Color(0x55FFD3E0)),
        ),
        const Positioned(
          top: 230,
          left: -55,
          child: _PastelOrb(size: 130, color: Color(0x44D4F0EA)),
        ),
        Positioned.fill(child: child),
      ],
    ),
  );
}

class _PastelOrb extends StatelessWidget {
  const _PastelOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
