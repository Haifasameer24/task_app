import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_course/screens/setting_screen.dart';
import 'package:heroicons/heroicons.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();

}

class _PasswordScreenState extends State<PasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obsecurePassword = true;
  bool _newPassword=true;
  bool _confirmPassword=true;


  // Controllers common
  final oldPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final isLoading = false.obs;

  bool hasPasswordProvider = false;

  @override
  void initState() {
    super.initState();
    // Call check after widget built to avoid async issues in initState
    Future.microtask(() => _checkProviders());
  }

  Future<void> _checkProviders() async {
    await _auth.currentUser?.reload(); // Refresh user data from Firebase
    final user = _auth.currentUser!;
    final providers = user.providerData.map((e) => e.providerId).toList();
    setState(() {
      hasPasswordProvider = providers.contains('password');
    });
  }


  Future<void> _updatePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirm = confirmController.text.trim();



    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }
    if (newPassword != confirm) {
      Get.snackbar("Error", "New passwords do not match");
      return;
    }

    // ✅ عرض Dialog تأكيد
    final confirmChange = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("sure"),
        content: const Text("Are you sure you want to change your password?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    // إذا المستخدم اختار "لا" أو أغلق الديالوج
    if (confirmChange != true) return;

    try {
      isLoading.value = true;
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

      // ✅ عرض رسالة نجاح
      Get.snackbar("Success", "Password updated successfully");

      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll((SettingsPage()));

      });

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "An error occurred while updating the password");
    } finally {
      isLoading.value = false;
    }
  }


  Widget _buildUpdatePassword() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Update your current account password.",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: oldPasswordController,
          obscureText: _obsecurePassword,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.black),
          decoration: InputDecoration(
            prefixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obsecurePassword = !_obsecurePassword;
                });
              },
              child: HeroIcon(
                _obsecurePassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                style: HeroIconStyle.outline,
                color: theme.iconTheme.color,
                size: 24,
              ),
            ),
            hintText: "Current password",
            hintStyle: TextStyle(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: _newPassword,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.black),
          decoration: InputDecoration(
            prefixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _newPassword = !_newPassword;
                });
              },
              child: HeroIcon(
                _newPassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                style: HeroIconStyle.outline,
                color: theme.iconTheme.color,
                size: 24,
              ),
            ),
            hintText: "New password",
            hintStyle: TextStyle(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmController,
          obscureText: _confirmPassword,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.black),
          decoration: InputDecoration(
            prefixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _confirmPassword = !_confirmPassword;
                });
              },
              child: HeroIcon(
                _confirmPassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                style: HeroIconStyle.outline,
                color: theme.iconTheme.color,
                size: 24,
              ),
            ),
            hintText: "Confirm New password",
            hintStyle: TextStyle(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }
            return ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text("Update"),
            );
          }),
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildUpdatePassword(),
      ),
    );
  }
}
