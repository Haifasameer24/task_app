import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  Future<void> _setPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("خطأ", "جميع الحقول مطلوبة");
      return;
    }
    if (password != confirm) {
      Get.snackbar("خطأ", "كلمة المرور غير متطابقة");
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        // ربط الباسورد بالحساب
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
        box.write("seen_onboarding", true);

        // تحميل المهام وفتح الصفحة الرئيسية
        Get.put(TaskController());
        Get.offAll(() => HomeScreen());

        Get.snackbar("تم", "تم تعيين كلمة المرور بنجاح");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("خطأ", e.message ?? "حدث خطأ أثناء إنشاء كلمة المرور");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: InputDecoration(
                hintText: 'password',
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              )),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: isLoading.value ? null : _setPassword,
              child: isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("save"),
            )),
          ],
        ),
      ),
    );
  }
}
