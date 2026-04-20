import 'dart:async';
import 'package:flutter/material.dart';
import '../core/logo_painter.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Timer(const Duration(milliseconds: 2800), widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryRed = Color(0xFFFF3B30);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _pulse,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryRed.withOpacity(0.05),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(64, 64),
                    painter: LifeOSLogoPainter(
                      strokeColor: theme.colorScheme.onBackground,
                      dotColor: primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'LIFEOS',
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _pulse,
              child: Text(
                'Initializing intelligence layer',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}