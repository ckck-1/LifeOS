import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- TOP: Skip Button ---
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Handle skip
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- MIDDLE: Image/Robot Card ---
              Expanded(
                flex: 12, // Increased flex to make card larger
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      40,
                    ), // More rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.12,
                        ), // Stronger shadow
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Stack(
                      children: [
                        // The Robot Image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/robot.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.android,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                        // --- Gradient Blend Mask ---
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.white, // Blends into the card bottom
                                ],
                                stops: [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTTOM: Text and Navigation ---
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPageIndicator(true),
                        _buildPageIndicator(false),
                        _buildPageIndicator(false),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Title
                    const Text(
                      'From chaos to control.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34, // Slightly larger
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -1.0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Description
                    Text(
                      'AI companion that turns chaos into\nclarity and ambition into real results.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    // Navigation Buttons
                    _buildNavigationButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Page Indicators
  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 18 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Helper Widget for Bottom Navigation Buttons
  Widget _buildNavigationButtons() {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () {},
          ),
          Container(height: 25, width: 1, color: Colors.grey[200]),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
