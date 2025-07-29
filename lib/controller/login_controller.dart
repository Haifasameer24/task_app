import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/app_routers.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/screens/splash_screen.dart';

import '../screens/home_screen.dart';
import 'addCatgory_controller.dart';

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
      Get.put(CategoryController());
      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل الدخول: ${e.toString()}");
    }
    isLoading.value = false;
  }

  Future<void> logout() async {
    final isGuest = box.read("is_guest") ?? false;
    final uid = box.read("id");

    if (isGuest && uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        final categoriesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('categories')
            .get();

        for (var doc in categoriesSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print("Error deleting guest data: $e");
      }

      await FirebaseAuth.instance.signOut();
      await box.erase();

      // امسح بيانات ال CategoryController في الذاكرة
      if (Get.isRegistered<CategoryController>()) {
        final catCtrl = Get.find<CategoryController>();
        catCtrl.categories.clear();
        catCtrl.clear();
        Get.delete<CategoryController>(); // احذف الـ Controller من GetX
      }
    } else {
      await FirebaseAuth.instance.signOut();

    }

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
      await box.write("is_guest", false);
      await box.write("seen_onboarding", true);
    }
  }

  String generateGuestName() {
    final randomNumber = DateTime.now().millisecondsSinceEpoch.remainder(10000);
    return "Guest_$randomNumber";
  }

  Future<void> signInAsGuest() async {
    isLoadingguest.value = true;
    try {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final user = result.user!;
      final guestName = generateGuestName();

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "uid": user.uid,
          "name": guestName,
          "email": "",
          "createdAt": DateTime.now().toIso8601String(),
        });
      }

      await box.write("id", user.uid);
      await box.write("name", guestName);
      await box.write("email", "");
      await box.write("create_date", DateTime.now().toIso8601String());
      await box.write("is_logged_in", true);
      await box.write("is_guest", true);
      await box.write("seen_onboarding", true);

      // حذف أي Controller سابق وإعادة إنشاء جديد نظيف
      if (Get.isRegistered<CategoryController>()) {
        Get.delete<CategoryController>();
      }
      Get.put(CategoryController());

      if (Get.isRegistered<TaskController>()) {
        Get.delete<TaskController>();
      }
      Get.put(TaskController());

      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل الدخول كزائر: ${e.toString()}");
    } finally {
      isLoadingguest.value = false;
    }
  }

}
