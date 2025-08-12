import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/screens/home_screen.dart';

import '../app_routers.dart';
import '../models/user_model.dart';
import 'addCatgory_controller.dart';

class SignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  final box = GetStorage();
  final isSignup=false.obs;
  Future<void> register() async {
    isSignup.value = true;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = passwordConfirmController.text.trim();

    // التحقق من الاسم
    if (name.isEmpty) {
      Get.snackbar("Error", "Please enter your name");
      isSignup.value = false;
      return;
    }

    // التحقق من الإيميل
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      isSignup.value = false;
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar("Error", "Please enter a valid email address");
      isSignup.value = false;
      return;
    }

    // التحقق من كلمة السر
    if (password.isEmpty) {
      Get.snackbar("Error", "Please enter your password");
      isSignup.value = false;
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      isSignup.value = false;
      return;
    }

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (!hasLetter || !hasNumber || !hasSpecialChar) {
      Get.snackbar(
        "Error",
        "Password must contain at least one letter, one number, and one special character",
      );
      isSignup.value = false;
      return;
    }

    // التحقق من تطابق كلمة السر
    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      isSignup.value = false;
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        uid: cred.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());

      final oldGuestId = box.read("id");
      if (oldGuestId != null && box.read("is_guest") == true) {
        // نسخ المهام من الضيف
        final guestTasksSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(oldGuestId)
            .collection('tasks')
            .get();

        for (var doc in guestTasksSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('tasks')
              .doc(doc.id)
              .set(doc.data());
        }

        // حذف المهام من الضيف
        for (var doc in guestTasksSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(oldGuestId)
              .collection('tasks')
              .doc(doc.id)
              .delete();
        }

        // نسخ التصنيفات من الضيف
        final guestCategoriesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(oldGuestId)
            .collection('categories')
            .get();

        for (var doc in guestCategoriesSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .doc(doc.id)
              .set(doc.data());
        }

        // حذف تصنيفات الضيف (اختياري)
        for (var doc in guestCategoriesSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(oldGuestId)
              .collection('categories')
              .doc(doc.id)
              .delete();
        }
      }

      // تحديث التخزين المحلي
      await box.write("id", user.uid);
      await box.write("name", user.name);
      await box.write("email", user.email);
      await box.write("create_date", user.createdAt.toString());
      await box.write("is_logged_in", true);
      await box.write("is_guest", false);

      // تحميل البيانات بعد التسجيل
      final taskController = Get.put(TaskController());
      final cat = Get.put(CategoryController());
      await taskController.loadTasksForUser(user.uid);
      await cat.loadCatForUser(user.uid);

      isSignup.value = false;

      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
      isSignup.value = false;
    }
  }



}