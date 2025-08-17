import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:heroicons/heroicons.dart';
import 'home_screen.dart';
import '../controller/task_controller.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String email;
  const CreatePasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();
  bool _newPassword=true;
  bool _confirmPassword=true;

  Future<void> _setPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }
    if (password != confirm) {
      Get.snackbar("Error", "New passwords do not match");
      return;
    }

    // عرض Dialog تأكيد
    final confirmSet = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sure"),
        content: const Text("Are you sure to add new password?"),
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

    if (confirmSet != true) return;

    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final cred = EmailAuthProvider.credential(
          email: widget.email,
          password: password,
        );
        await user.linkWithCredential(cred);

        // تحديث التخزين المحلي
        await box.write("id", user.uid);
        await box.write("name", user.displayName ?? 'User');
        await box.write("email", widget.email);
        await box.write("photoUrl", user.photoURL ?? '');
        await box.write("create_date", DateTime.now().toIso8601String());
        await box.write("is_logged_in", true);
        await box.write("is_guest", false);
        await box.write("seen_onboarding", true);

        // تحميل المهام وفتح الصفحة الرئيسية
        Get.put(TaskController());
        Get.offAll(() => HomeScreen());

        Get.snackbar("Done", "Done added new password");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "حدث خطأ أثناء إنشاء كلمة المرور");
    } finally {
      isLoading.value = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Please set a password for your account so that you can log in later using your email and password.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
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
              ),),
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
                hintText: "Confirm password",
                hintStyle: TextStyle(color: theme.hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
              ),),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                if (isLoading.value) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                return ElevatedButton(
                  onPressed: _setPassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  child: const Text("Save"),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
