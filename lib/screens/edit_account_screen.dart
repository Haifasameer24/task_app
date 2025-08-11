import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> _createPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }
    if (password != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.linkWithCredential(cred);
        await _auth.currentUser?.reload(); // Refresh user data after linking
        await _checkProviders();

        Get.snackbar("Success", "Password has been set successfully");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "An error occurred while setting the password");
    } finally {
      isLoading.value = false;
    }
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

    try {
      isLoading.value = true;
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);
      Get.snackbar("Success", "Password updated successfully");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "An error occurred while updating the password");
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildUpdatePassword() {
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
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Current Password',
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'New Password',
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm New Password',
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton(
          onPressed: isLoading.value ? null : _updatePassword,
          child: isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Update"),
        )),
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
