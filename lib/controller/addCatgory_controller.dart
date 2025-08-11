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

  Future<void> editCategory(BuildContext context, String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("User not logged in", "Please login first...");
      return;
    }

    final name = CatnameController.text.trim();
    final desc = CatdescController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      Get.snackbar("خطأ", "Please fill all fields");
      return;
    }

    if (selectedColor == null) {
      Get.snackbar("خطأ", "Please choose a color");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .update({
        'name': name,
        'description': desc,
        'color': selectedColor!.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      clear();
      Navigator.pop(context);
      Get.snackbar("Updated", "Category updated successfully");
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
  Future<void> deleteCategoryAndTasks(Category category) async {
    final userId = GetStorage().read("id");
    if (userId == null) return;

    try {
      final firestore = FirebaseFirestore.instance;

      // 1️⃣ جلب جميع المهام التابعة للكاتيجوري
      final tasksSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('cat', isEqualTo: category.name)
          .get();

      if (tasksSnapshot.docs.isNotEmpty) {
        // حذف جميع المهام المرتبطة
        for (var doc in tasksSnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // 2️⃣ حذف الكاتيجوري نفسه من Firestore
      await firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(category.id)
          .delete();

      // 3️⃣ تحديث القائمة المحلية مباشرة
      final categoryController = Get.find<CategoryController>();
      categoryController.categories.removeWhere((c) => c.id == category.id);

      // 4️⃣ عرض إشعار
      Get.snackbar(
        "تم الحذف",
        "Deleted Category and related tasks",
      );
    } catch (e) {
      print("❌ خطأ أثناء الحذف: $e");
      Get.snackbar("Error", "تعذر حذف الكاتيجوري");
    }
  }

  Future<void> addCategoryDirect(String name, String desc, Color color) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
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
        'color': color.value,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      fetchCategories();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> editCategoryDirect(String id, String newName, String newDesc, Color newColor) async {
    final userId = GetStorage().read('id');
    if (userId == null) return;

    try {
      final oldCategoryIndex = categories.indexWhere((cat) => cat.id == id);
      if (oldCategoryIndex == -1) return;

      final oldCategory = categories[oldCategoryIndex];
      final oldName = oldCategory.name;

      // 1. تحديث الكاتيجوري نفسها في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(id)
          .update({
        'name': newName,
        'description': newDesc,
        'color': newColor.value,
      });

      // 2. تحديث الكاتيجوري في القائمة المحلية
      categories[oldCategoryIndex] = Category(
        id: id,
        name: newName,
        description: newDesc,
        color: newColor,
      );
      categories.refresh();

      // 3. تحديث كل المهام التي تحتوي الكاتيجوري القديم
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('cat', isEqualTo: oldName)
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in taskSnapshot.docs) {
        batch.update(doc.reference, {'cat': newName});
      }

      await batch.commit();

      // 4. لو تستخدم GetX للمهام أيضاً، لازم تحدث الـ tasks محلياً بعد التحديث
      final taskController = Get.find<TaskController>();
      for (var task in taskController.tasks) {
        if (task.cat == oldName) {
          task.cat = newName;
        }
      }
      taskController.tasks.refresh();

    } catch (e) {
      print("Error editing category and updating tasks: $e");
      Get.snackbar("Error", "Failed to update category and tasks");
    }
  }




  @override
  void onClose() {
    CatnameController.dispose();
    CatdescController.dispose();
    super.onClose();
  }
}
