import 'package:flutter/material.dart';
import 'package:korek_task/config/colors.dart';
import 'package:korek_task/screens/main_screen.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                const OnboardingStep(
                  lottiePath: 'assets/animation/79960-learning.json',
                  title: 'Discover PDFs',
                  description:
                      'Find and manage your PDFs easily with our advanced search feature.',
                ),
                const OnboardingStep(
                  lottiePath: 'assets/animation/onboarding1.json',
                  title: 'Multi-Language Support',
                  description:
                      'Supports both Arabic and English to make searching convenient.',
                ),
                OnboardingStep(
                  lottiePath: 'assets/animation/39992-walking.json',
                  title: 'Get Started',
                  description: 'Start searching for your PDFs now!',
                  onDone: () {},
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3, // Number of pages
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                curve: Curves.easeIn,
                height: 6,
                width: _currentIndex == index
                    ? 30
                    : 10, // Wider for the active page
                decoration: BoxDecoration(
                  color: AppColor.primiryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_currentIndex <
              2) // Show "Next" button on pages other than the last
            GestureDetector(
              onTap: _nextPage,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(3, 3),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.07),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (_currentIndex ==
              2) // Show "Get Started" button only on the last page
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MainPage(),
                ));
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColor.primiryColor,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingStep extends StatelessWidget {
  final String lottiePath;
  final String title;
  final String description;
  final VoidCallback? onDone;

  const OnboardingStep({
    required this.lottiePath,
    required this.title,
    required this.description,
    this.onDone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: Lottie.asset(
              lottiePath,
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
