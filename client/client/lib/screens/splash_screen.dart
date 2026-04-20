import 'dart:async';
import 'package:flutter/material.dart';
import '../core/logo_painter.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 0.6).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(64, 64),
              painter: LifeOSLogoPainter(strokeColor: theme.colorScheme.onBackground, dotColor: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text('LIFEOS', style: theme.textTheme.displayLarge),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _pulse,
              child: Text('Initializing intelligence layer', style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}