import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {"title": "LifeOS", "desc": "", "img": "assets/onboarding1.png"},
    {
      "title": "Welcome aboard",
      "desc": "We're glad you're here. Let's begin your journey.",
      "img": "assets/onboarding2.jpg",
    },
    {
      "title": "Vision Mapping",
      "desc": "Define Your Vision",
      "img": "assets/onboarding3.png",
    },
    {
      "title": "You're all set!",
      "desc": "Let's dive in and explore what's waiting for you.",
      "img": "assets/onboarding5.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _buildPage(i),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF40C4FF),
                        minimumSize: const Size(double.infinity, 60),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: widget.onFinish,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get started ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                _buildDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int i) {
    bool isFirstPage = i == 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isFirstPage) ...[
          // Placeholder for your images. In a real app, use Image.asset(_pages[i]['img']!)
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1D2635),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 80, color: Colors.white24),
            ),
          ),
          const SizedBox(height: 40),
        ],
        Text(
          _pages[i]['title']!,
          style: TextStyle(
            fontSize: isFirstPage ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (!isFirstPage) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _pages[i]['desc']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF7E8494)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (idx) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: idx == _currentPage ? 24 : 8,
          decoration: BoxDecoration(
            color: idx == _currentPage
                ? const Color(0xFF4CAF50)
                : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
