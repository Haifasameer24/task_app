import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  final RxBool isLoading = true.obs;
  final RxBool haveNotify = true.obs;

  @override
  void onInit() {
    super.onInit();
    streamTasks();
  }

  void streamTasks() {
    print("📡 streamTasks() بدأ تنفيذها");

    final user = box.read("id");
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }
    isLoading.value = true;

    FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .collection("tasks")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) async {
      final fetchedTasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      tasks.value = fetchedTasks;
      isLoading.value = false;

      for (final task in fetchedTasks) {
        final scheduledKey = "notified_${task.id}";
        final alreadyScheduled = box.read(scheduledKey) == true;

        print("🧩 تحقق من المهمة: ${task.name}");
        print("   🔸 haveNotify: ${task.haveNotify}");
        print("   🔸 dueDate: ${task.dueDate} > الآن: ${DateTime.now()} → ${task.dueDate.isAfter(DateTime.now())}");
        print("   🔸 alreadyScheduled: $alreadyScheduled");

        if (task.haveNotify &&
            task.dueDate.isAfter(DateTime.now()) &&
            !alreadyScheduled) {
          debugPrint("📲 جدولة إشعار:");
          debugPrint("• ID: ${task.id}");
          debugPrint("• Title: ${task.name}");
          debugPrint("• Desc: ${task.description}");
          debugPrint("• DateTime: ${task.dueDate}");

          try {
            await NotificationService.scheduleNotification(
              id: task.id.hashCode,
              title: task.name,
              body: task.description,
              year: task.dueDate.year,
              month: task.dueDate.month,
              day: task.dueDate.day,
              hour: task.dueDate.hour,
              minute: task.dueDate.minute,
            );
            box.write(scheduledKey, true);
          } catch (e) {
            print("❌ خطأ أثناء جدولة الإشعار: $e");
          }
        }
      }
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

    final newTaskId = await addTask(dueDate: taskDate!);
    if (newTaskId == null) return;

    if (haveNotify.value == true) {
      await NotificationService.scheduleNotification(
        id: newTaskId.hashCode,
        title: "$taskTitle",
        body: "$taskDesc",
        year: year!,
        month: month!,
        day: day!,
        hour: hour!,
        minute: minute!,
      );
      box.write("notified_$newTaskId", true);
    }
  }

  Future<String?> addTask({required DateTime dueDate}) async {
    final user = box.read("id");
    if (user == null) {
      Get.snackbar("Error", "User not logged in");
      return null;
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
      haveNotify: haveNotify.value,
    );

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson());
      Get.back();
      Get.snackbar("Done", "Done Add task successfully ✅");

      clearFields();
      return taskId;
    } catch (e) {
      Get.snackbar("فشل", e.toString());
      return null;
    }
  }
  Future<void> deleteTask(TaskModel task) async {
    final userId = GetStorage().read("id");
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .delete();

      tasks.remove(task);
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
  Future<bool> changeTaskStatus(TaskModel task, TaskStatus newStatus) async {
    // ترجع true إذا تم التغيير، false إذا ضيف (ممنوع)
    bool isGuest = box.read("is_guest") ?? false;
    if (isGuest) {
      return false; // ممنوع التغيير
    }

    final userId = box.read("id");
    if (userId == null) return false;

    task.status = newStatus;
    tasks.refresh();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update({'status': newStatus.name});
      return true;
    } catch (e) {
      print("Error updating task status: $e");
      return false;
    }
  }
  void setDateTime(DateTime dateTime) {
    realDueDate = dateTime;
    taskDate = dateTime;
    taskTimeController.text = dateTime.toString();

    year = dateTime.year;
    month = dateTime.month;
    day = dateTime.day;
    hour = dateTime.hour;
    minute = dateTime.minute;
  }

  Future<void> prepareAndSaveTask(DateTime? selectedDateTime) async {
    if (selectedDateTime != null) {
      setDateTime(selectedDateTime);
    }

    taskTitle = taskNameController.text.trim();
    taskDesc = taskDescriptionController.text.trim();

    await addTaskWithNotification();
  }

  Future<void> loadTasksForUser(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();

      final loadedTasks = snapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data());
      }).toList();

      tasks.value = loadedTasks;
      tasks.refresh();
    } catch (e) {
      print("Error loading tasks: $e");
    }
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
    // احذف dispose() لتجنب الخطأ
    clearFields();
    super.onClose();
  }
}