import 'package:flutter/material.dart';
import 'package:frontendtwo/features/onboarding/presentation/widgets/feature_carousel.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/dot_indicator.dart';
import '../../data/onboarding_model.dart';
import 'package:frontendtwo/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              final page = onboardingPages[index];
              return Column(
                children: [
                  const SizedBox(height: 80),
                  // Image/Asset Area
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: page.image != null 
                          ? Image.asset(page.image!, fit: BoxFit.cover)
                          : Container(color: AppColors.surface),
                      ),
                    ),
                  ),
                  // Text Area
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.title,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.subtitle,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          if (index == onboardingPages.length - 1)
                            _buildGetStartedButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Dot Indicators at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingPages.length,
                (index) => DotIndicator(isActive: _currentIndex == index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
  return Container(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAI,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      onPressed: () {
        // Navigates to LoginScreen and removes Onboarding from the stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: const Text(
        "Get started →",
        style: TextStyle(
          color: AppColors.background, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
      ),
    ),
  );
}
}