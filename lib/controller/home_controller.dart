import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController{

  final TextEditingController nameController = TextEditingController();
    final box = GetStorage();
    var userName=''.obs;
    @override
    void onInit(){
      super.onInit();
      userName.value=box.read("name") ??"";
    }
  Future<void> updateUserName(String newName) async {
    final uid = box.read("id"); // جلب uid من GetStorage

    if (uid == null) {
      Get.snackbar("Error", "User ID not found in storage.");
      return;
    }

    try {
      // تحديث الاسم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text,
      });

      // تحديث الاسم في GetStorage
      await box.write("name", newName);
      // تحديث المتغير المراقب
      userName.value = newName;

      Get.snackbar("Success", "Name updated successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to update name: $e");
      print(e);
    }
  }




}