import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<_OnboardingPageModel> pages = [
    _OnboardingPageModel(
      title: "Organize Your Tasks",
      description: "Plan and organize your daily tasks easily.",
      isDark: "assets/lottie/task1.json",
      isLight:"assets/lottie/dark_task1.json",
    ),
    _OnboardingPageModel(
      title: "Track Your Progress",
      description: "Keep track of completed and pending tasks.",
      isDark: "assets/lottie/task2.json",
      isLight:"assets/lottie/task2.json",
    ),
    _OnboardingPageModel(
      title: "Achieve More",
      description: "Boost your productivity with smart task management.",
      isDark:"assets/lottie/task3.json",
      isLight: "assets/lottie/task3.json",
    ),
  ];

  void _onNextPressed() {
    if (currentIndex < pages.length - 1) {
      _pageController.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      GetStorage().write("seen_onboarding", true);
      Get.off(LoginScreen());
    }
  }

  void _onSkipPressed() {
    Get.off(() => HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _onSkipPressed,
                      child: Text(
                        "Skip",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        final page = pages[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              isDark ? page.isLight : page.isDark,
                              height: 250,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              page.title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onBackground.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? colorScheme.primary
                              : colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 96), // Space for FAB
                ],
              ),
            ),

            // ✅ زر دائري في الأسفل يمين
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: _onNextPressed,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: Icon(
                  currentIndex == pages.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageModel {
  final String title;
  final String description;
  final String isDark;
  final String isLight;

  _OnboardingPageModel({
    required this.title,
    required this.description,
    required this.isDark,
    required this.isLight,
  });
}
