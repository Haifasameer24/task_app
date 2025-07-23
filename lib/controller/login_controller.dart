import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/app_routers.dart';
import 'package:getx_course/screens/splash_screen.dart';

import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final box = GetStorage();
  final isLoading = false.obs;

  Future<void> login() async {
    isLoading.value = true;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      await _setUserLoggedIn();
      Get.offAll(HomeScreen());


    }catch(e){
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
    Get.offAll(SplashScreen());
  }

  Future<void> _setUserLoggedIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if(_auth.currentUser != null){
      String uid = _auth.currentUser!.uid;
      DocumentReference userRef = _firestore.collection("users").doc(uid);
      DocumentSnapshot userDoc = await userRef.get();
      if(userDoc.exists){
        var userData = userDoc.data() as Map<String, dynamic>;
        await box.write("id", uid);
        await box.write("name", userData["name"]);
        await box.write("email", userData["email"]);
        await box.write("create_date", userData["createdAt"]);        }
        await box.write("is_logged_in", true);
        box.write("seen_onboarding", true);

    }
  }
}