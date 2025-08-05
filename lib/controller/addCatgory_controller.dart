import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/task_controller.dart';
import '../models/Category.dart';


class CategoryController extends GetxController {
  final CatnameController = TextEditingController();
  final CatdescController = TextEditingController();
  Color? selectedColor;

  final categories = <Category>[].obs;


  RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }
  void fetchCategories() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ❌ لا تمنع الزائر، خليه يشوف بياناته طول ما هو فاتح التطبيق
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      categories.value = snapshot.docs.map((doc) {
        return Category(
          id: doc.id,
          name: doc['name'],
          description: doc['description'],
          color: Color(doc['color']),
        );
      }).toList();
    });
  }

  void clear() {
    CatnameController.clear();
    CatdescController.clear();
    selectedColor = null;
  }

  Future<void> addCategory(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("User not logged in", "login first....");
      return;
    }

    final name = CatnameController.text.trim();
    final desc = CatdescController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      Get.snackbar("خطأ", "pleace file all field");
      return;
    }

    if (selectedColor == null) {
      Get.snackbar("خطأ", "choose color");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add({
        'name': name,
        'description': desc,
        'color': selectedColor!.value,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      clear();
      Navigator.pop(context);
      Get.snackbar("Added", "Added successful");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  Future<void> loadCatForUser(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      final loadedCategories = snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();

      categories.value = loadedCategories;
      categories.refresh(); // لتحديث الواجهة إذا لزم
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  List<Category> get filteredCategories {
    if (searchText.value.trim().isEmpty) return categories;
    return categories.where((cat) {
      return cat.name.toLowerCase().contains(searchText.value.toLowerCase());
    }).toList();
  }
  Color? getColorByCategoryName(String categoryName) {
    final cat = categories.firstWhereOrNull((c) => c.name == categoryName);
    return cat?.color;
  }
  // Future<void> deleteCategoryAndTasks(Category category) async {
  //   final userId = GetStorage().read("id");
  //   final taskController = Get.find<TaskController>(); // عشان نتحكم بالمهام
  //   if (userId == null) return;
  //
  //   try {
  //     final firestore = FirebaseFirestore.instance;
  //
  //     // 1️⃣ حذف جميع المهام المرتبطة بهذه الكاتيجوري من Firestore
  //     final tasksSnapshot = await firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('tasks')
  //         .where('cat', isEqualTo: category.id)
  //         .get();
  //
  //     for (var doc in tasksSnapshot.docs) {
  //       await doc.reference.delete();
  //     }
  //
  //     // 2️⃣ حذف الكاتيجوري نفسه من Firestore
  //     await firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('categories')
  //         .doc(category.id)
  //         .delete();
  //
  //     // 3️⃣ تحديث القوائم المحلية (حذف المهام من الـ TaskController)
  //     taskController.tasks.removeWhere((task) => task.cat == category.name);
  //
  //     // 4️⃣ تحديث قائمة الكاتيجوري إذا موجودة عندك محليًا
  //     // categoryController.categories.removeWhere((c) => c.id == category.id);
  //
  //     Get.snackbar("Category Deleted", "All related tasks removed");
  //   } catch (e) {
  //     print("Error deleting category: $e");
  //     Get.snackbar("Error", "Could not delete category");
  //   }
  // }


  @override
  void onClose() {
    CatnameController.dispose();
    CatdescController.dispose();
    super.onClose();
  }
}
