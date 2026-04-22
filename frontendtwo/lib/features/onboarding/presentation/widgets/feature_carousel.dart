class OnboardingData {
  final String title;
  final String subtitle;
  final String? image;
  final bool isCarousel;

  OnboardingData({
    required this.title,
    required this.subtitle,
    this.image,
    this.isCarousel = false,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(title: "Welcome aboard", subtitle: "We’re glad you’re here. Let’s begin your journey.", image: "assets/images/second_brain.png"),
  OnboardingData(title: "Vision Mapping", subtitle: "Define Your Vision", image: "assets/images/mountain.png", isCarousel: true),
  OnboardingData(title: "Deep Flow", subtitle: "Own Your Day", image: "assets/images/hourglass.png", isCarousel: true),
  OnboardingData(title: "You’re all set!", subtitle: "Let’s dive in and explore what’s waiting for you.", image: "assets/images/rocket.png"),
];