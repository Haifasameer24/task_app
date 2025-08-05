import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:get/get.dart';
import 'package:getx_course/controller/login_controller.dart';
import 'package:getx_course/screens/signup_screen.dart';
import 'package:heroicons/heroicons.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = Get.put(LoginController());
  bool _obsecurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/splash.json",
                width: 200,
                // لو تحب ممكن تغير ألوان الأنيميشن حسب الوضع لكن غالباً مش ضروري
              ),
              SizedBox(height: 10),
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      key: Key('user_email'),
                      controller: loginController.emailController,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        prefixIcon: HeroIcon(HeroIcons.envelope,style: HeroIconStyle.outline, color: theme.iconTheme.color),
                        hintText: "Enter your email",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      key: Key('user_password'),
                      controller: loginController.passwordController,
                      obscureText: _obsecurePassword,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        prefixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obsecurePassword = !_obsecurePassword;
                            });
                          },
                          child: HeroIcon(
                            _obsecurePassword ? HeroIcons.eyeSlash: HeroIcons.eye,
                            style: HeroIconStyle.outline,
                            color: theme.iconTheme.color,
                            size: 24,
                          ),
                        ),
                        hintText: "Enter your password",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                      ),
                    ),
                    SizedBox(height: 20),
                    // مكان الزر داخل الـ Column بعد زر "Login" وزر "Sign Up"
                    Column(
                      children: [
                        // زر Login
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() {
                            if (loginController.isLoading.value) {
                              return const Center(child: CupertinoActivityIndicator());
                            }
                            return ElevatedButton(
                              onPressed: () {
                                loginController.login();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              child: Text("Login"),
                            );
                          }),
                        ),

                        SizedBox(height: 12),

                        // زر Login as Guest
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() {
                            if (loginController.isLoadingguest.value) {
                              return const Center(child: CupertinoActivityIndicator());
                            }
                            return ElevatedButton(
                              onPressed: () {
                                loginController.signInAsGuest();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              child: Text("Login as Guest"),
                            );
                          }),
                        ),

                        SizedBox(height: 16),

                        // خط مع OR
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // زر Sign in with Google
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() {
                            if (loginController.isGoogle.value) {
                              return const Center(child: CupertinoActivityIndicator());
                            }
                            return OutlinedButton.icon(
                              onPressed: () {
                                loginController.signInWithGoogle();
                              },
                              icon: Image.asset(
                                'assets/images/google_image.jpg',
                                height: 20,
                                width: 24,
                              ),
                              label: Text(
                                "Sign in with Google",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color:Colors.grey, // لون البوردر حسب الثيم
                                  width: 2,
                                ),
                                foregroundColor:Colors.black, // لون النص
                                backgroundColor: Colors.white, // بدون خلفية
                              ),
                            );
                          }),
                        ),


                        SizedBox(height: 16),

                        // زر Sign Up
                        TextButton(
                          onPressed: () {
                            Get.offAll(() => SignupScreen());
                          },
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    )


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
