import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/tsks_model.dart';
import '../services/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskController extends GetxController {
  final taskNameController = TextEditingController();
  final taskTimeController = TextEditingController();
  final taskDescriptionController = TextEditingController();
  final taskCatController = TextEditingController();

  final box = GetStorage();
  DateTime? realDueDate;
  String? taskTitle;
  String? taskDesc;
  DateTime? taskDate;
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minute;

  RxList<TaskModel> tasks = <TaskModel>[].obs;
  RxString searchText = ''.obs;

  final RxBool isNotificationOn = true.obs;
  final RxBool isLoading=true.obs;
  final RxBool haveNotify = true.obs;



  @override
  void onInit() {
    super.onInit();
    streamTasks();
  }

  void streamTasks() {
    final user = box.read("id");
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }
    isLoading.value=true;

    FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .collection("tasks")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      tasks.value = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
      isLoading.value=false;
    });
  }

  List<TaskModel> get filteredTasks {
    if (searchText.value.trim().isEmpty) return tasks;
    final query = searchText.value.toLowerCase();
    return tasks.where((task) {
      return task.name.toLowerCase().startsWith(query);
    }).toList();
  }

  Future<void> addTaskWithNotification() async {
    if (taskTitle == null || taskTitle!.isEmpty ||
        taskDesc == null || taskDesc!.isEmpty ||
        taskDate == null ||
        year == null || month == null || day == null || hour == null || minute == null) {
      Get.snackbar("خطأ", "يرجى تعبئة كل الحقول وتحديد التاريخ والوقت");
      return;
    }

    final scheduledDate = tz.TZDateTime(
      tz.local,
      year!,
      month!,
      day!,
      hour!,
      minute!,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      Get.snackbar("خطأ", "يجب اختيار وقت في المستقبل");
      return;
    }
    await addTask(dueDate: taskDate!);

    if(haveNotify.value == true) {
      await NotificationService.scheduleNotification(
        title: "$taskTitle",
        body: "$taskDesc",
        year: year!,
        month: month!,
        day: day!,
        hour: hour!,
        minute: minute!,
      );
    }
  }
  Future<void> addTask({required DateTime dueDate}) async {
    final user = box.read("id");
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }
    final taskId = FirebaseFirestore.instance.collection('tasks').doc().id;
    final task = TaskModel(
      id: taskId,
      name: taskNameController.text.trim(),
      description: taskDescriptionController.text.trim(),
      userId: user,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      status: TaskStatus.upcoming,
      cat: taskCatController.text.trim(),
      haveNotify: haveNotify.value
    );

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson());
      Get.back();
      Get.snackbar("نجاح", "تم إضافة المهمة بنجاح ✅");

      clearFields();
    } catch (e) {
      Get.snackbar("فشل", e.toString());
    }
    update();
  }

  void clearFields() {
    taskNameController.clear();
    taskTimeController.clear();
    taskDescriptionController.clear();
    taskCatController.clear();
    realDueDate = null;
  }

  @override
  void onClose() {
    taskNameController.dispose();
    taskTimeController.dispose();
    taskDescriptionController.dispose();
    taskCatController.dispose();
    super.onClose();
  }
}
