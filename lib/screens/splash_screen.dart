import 'package:flutter/material.dart';
import 'package:korek_task/screens/on_boarding_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  bool _visible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInExpo,
    );
    _checkOnboardingStatus();
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? onboardingCompleted = prefs.getBool('onboarding_completed');

    // Delay to show the splash screen for a while
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to the onboarding page if onboarding is not completed
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const OnBoardingPage(),
      ),
    );
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _visible = true;
        _controller.forward();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 85),
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/animation/Animation_search1.json', // Your splash screen animation path
                width: 280,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
                height: 20), // Add some space between animation and text
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: const Text(
                    'Welcome to PDF Finder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Customize text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
