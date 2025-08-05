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
    isSignup.value=true;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = passwordConfirmController.text.trim();

    if (password != confirmPassword) {
      Get.snackbar("Error", "Password Not Match");
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

        // 🔁 نسخ التصنيفات من الضيف
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

      } else {
        // ⚙️ إنشاء تصنيفات افتراضية للمستخدم الجديد (إذا لم يكن ضيف)
        final defaultCategories = [
          {
            'name': 'Work',
            'description': 'Work-related tasks',
            'color': Colors.blue.value,
          },
          {
            'name': 'Personal',
            'description': 'Personal tasks',
            'color': Colors.green.value,
          },
        ];

        for (var cat in defaultCategories) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('categories')
              .add(cat);
        }
      }

      //  تحديث التخزين المحلي
      await box.write("id", user.uid);
      await box.write("name", user.name);
      await box.write("email", user.email);
      await box.write("create_date", user.createdAt.toString());
      await box.write("is_logged_in", true);
      await box.write("is_guest", false);

      //  تحميل البيانات بعد التسجي
      final taskController = Get.put(TaskController());
      final cat = Get.put(CategoryController());
      await taskController.loadTasksForUser(user.uid);
      await cat.loadCatForUser(user.uid);
      isSignup.value=false;

      Get.offAll(HomeScreen());

    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
    }
  }


}