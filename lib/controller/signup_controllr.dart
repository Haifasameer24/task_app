import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/screens/home_screen.dart';

import '../app_routers.dart';
import '../models/user_model.dart';

class SignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  final box = GetStorage();

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = passwordConfirmController.text.trim();

    if (password != confirmPassword) {
      Get.snackbar("Error", "Password Not Match");
    }else{
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password
        );
        final user = AppUser (
            uid: cred.user!.uid,
            name: name,
            email: email,
            createdAt: DateTime.now()
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(user.toJson());

        await box.write("id", user.uid.toString());
        await box.write("name", user.name.toString());
        await box.write("email", user.email.toString());
        await box.write("create_date", user.createdAt.toString());
        await box.write("is_logged_in", true);



      Get.offAll(HomeScreen());
      }catch(e) {
        Get.snackbar("Error", e.toString());
        print(e);
      }
    }
  }
}