import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/signup_controllr.dart';
import 'package:heroicons/heroicons.dart';
import 'package:lottie/lottie.dart';

import '../controller/login_controller.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obsecurePassword = true;
  bool _obsecureConfirmPassword = true;
  final GetStorage box = GetStorage();


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final loginController = Get.put(LoginController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.08,
            horizontal: screenWidth * 0.08,
          ),
          child: Column(
            children: [
              Lottie.asset("assets/lottie/splash.json", width: screenWidth * 0.4),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.nameController,
                icon: HeroIcons.user,
                hint: "Enter your name",
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.emailController,
                icon: HeroIcons.envelope,
                hint: "Enter E-mail",
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.passwordController,
                icon: _obsecurePassword ? HeroIcons.eye : HeroIcons.eyeSlash,
                hint: "Enter your password",
                obscure: _obsecurePassword,
                toggleObscure: () {
                  setState(() => _obsecurePassword = !_obsecurePassword);
                },
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.passwordConfirmController,
                icon: _obsecureConfirmPassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                hint: "Confirm password",
                obscure: _obsecureConfirmPassword,
                toggleObscure: () {
                  setState(() => _obsecureConfirmPassword = !_obsecureConfirmPassword);
                },
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.03),

              // زر تسجيل الدخول العادي
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  if (controller.isSignup.value) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      controller.register();
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
                    child: Text("SignUp"),
                  );
                }),
              ),
              SizedBox(height: 10,),
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
              TextButton(
                onPressed: () {
                  Get.offAll(() => LoginScreen());
                },
                child: Text(
                  "You have an account?",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required HeroIcons icon,
    required String hint,
    bool obscure = false,
    VoidCallback? toggleObscure,
    required ThemeData theme,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        prefixIcon: toggleObscure == null
            ? HeroIcon(icon, color: theme.iconTheme.color)
            : GestureDetector(
          onTap: toggleObscure,
          child: HeroIcon(icon, color: theme.iconTheme.color),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
      ),
    );
  }
}
