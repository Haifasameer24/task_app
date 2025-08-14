import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/screens/home_screen.dart';
import 'package:getx_course/screens/login_screen.dart';
import 'package:lottie/lottie.dart';

import 'onbording_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final box = GetStorage();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final isLoggedIn = box.read("is_logged_in") ?? false;
    final seenOnboarding = box.read("seen_onboarding") ?? false;

    if (isLoggedIn) {
      Get.off(() => HomeScreen());
    } else if (seenOnboarding) {
      Get.off(() => LoginScreen());
    } else {
      await Get.to(() => OnboardingScreen());
      Get.off(() => LoginScreen());

      box.write("seen_onboarding", true);

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Lottie.asset(
              isDarkMode
                  ? "assets/lottie/dark_splash.json"
                  : "assets/lottie/splash.json",
              width: 250,
            ),
          ),
        ),
      ),
    );
  }
}
