import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/app_routers.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/screens/splash_screen.dart';

import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final box = GetStorage();
  final isLoading = false.obs;
  final isLoadingguest = false.obs;

  Future<void> login() async {
    isLoading.value = true;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      await _setUserLoggedIn();
      Get.put(TaskController());
      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("Error", "Because ${e.toString()}");
    }
    isLoading.value = false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await box.remove("id");
    await box.remove("name");
    await box.remove("email");
    await box.remove("create_date");
    await box.write("is_logged_in", false);
    await box.write("is_guest", false);
    Get.offAll(SplashScreen());
  }

  Future<void> _setUserLoggedIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      DocumentReference userRef = _firestore.collection("users").doc(uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        await box.write("id", uid);
        await box.write("name", userData["name"]);
        await box.write("email", userData["email"]);
        await box.write("create_date", userData["createdAt"]);
      }
      await box.write("is_logged_in", true);
      box.write("seen_onboarding", true);
    }
  }
  String generateGuestName() {
    final randomNumber = DateTime.now().millisecondsSinceEpoch.remainder(10000);
    return "Guest_$randomNumber";
  }

  Future<void> signInAsGuest() async {
    print("signInAsGuest called");

    isLoadingguest.value = true;
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      if (auth.currentUser == null) {
        UserCredential result = await auth.signInAnonymously();
        final user = result.user;
        final docRef = firestore.collection('users').doc(user!.uid);
        final doc = await docRef.get();

        // 🔄 إنشاء اسم ضيف جديد
        final guestName = generateGuestName();

        if (!doc.exists) {
          await docRef.set({
            "uid": user.uid,
            "name": guestName,
            "email": "",
            "createdAt": DateTime.now().toIso8601String(),
          });
        }

        // 📦 تخزين البيانات
        await box.write("id", user.uid);
        await box.write("name", guestName);
        await box.write("email", "");
        await box.write("create_date", DateTime.now().toIso8601String());
        await box.write("is_logged_in", true);
        await box.write("is_guest", true);
        box.write("seen_onboarding", true);

        Get.put(TaskController());
        Get.offAll(HomeScreen());
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل المستخدم الضيف: ${e.toString()}");
    } finally {
      isLoadingguest.value = false;
    }
  }

}