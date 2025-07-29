import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/signup_controllr.dart';
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
                icon: Icons.person,
                hint: "Enter your name",
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.emailController,
                icon: Icons.email,
                hint: "Enter E-mail",
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildTextField(
                controller: controller.passwordController,
                icon: _obsecurePassword ? Icons.visibility_off : Icons.visibility,
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
                icon: _obsecureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                hint: "Confirm password",
                obscure: _obsecureConfirmPassword,
                toggleObscure: () {
                  setState(() => _obsecureConfirmPassword = !_obsecureConfirmPassword);
                },
                theme: theme,
                isDark: isDark,
              ),
              SizedBox(height: screenHeight * 0.03),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                  ),
                  onPressed: () => controller.register(),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

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
    required IconData icon,
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
            ? Icon(icon, color: theme.iconTheme.color)
            : GestureDetector(
          onTap: toggleObscure,
          child: Icon(icon, color: theme.iconTheme.color),
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
