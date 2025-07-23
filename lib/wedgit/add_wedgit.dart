import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';

class AddButton extends StatefulWidget {
  AddButton({Key? key}) : super(key: key);

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  final taskController = Get.find<TaskController>();
  final categoryController = Get.find<CategoryController>();

  DateTime? selectedDateTime;
  int? hour;
  int? minute;
  int? day;
  int? month;
  int? year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskcontroller = Get.put(TaskController());

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController.taskNameController,
              decoration: InputDecoration(
                hintText: 'Task Name',
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),

            // وصف المهمة
            TextField(
              controller: taskController.taskDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description',
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),

            GestureDetector(
              onTap: () async {
                final pickedDateTime = await pickDateTime(context, initialDate: selectedDateTime ?? DateTime.now());
                if (pickedDateTime != null) {
                  setState(() {
                    selectedDateTime = pickedDateTime;
                    taskController.taskTimeController.text = pickedDateTime.toString();
                    taskController.realDueDate = pickedDateTime;

                    taskController.taskDate = pickedDateTime;
                    taskController.year = pickedDateTime.year;
                    taskController.month = pickedDateTime.month;
                    taskController.day = pickedDateTime.day;
                    taskController.hour = pickedDateTime.hour;
                    taskController.minute = pickedDateTime.minute;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: taskController.taskTimeController,
                  decoration: InputDecoration(
                    hintText: 'Select Due Date & Time',
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Obx(() {
              if (categoryController.categories.isEmpty) {
                return const Center(child: Text('Loading categories...'));
              }
              return SizedBox(
                width: 500,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Select Category',
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: taskController.taskCatController.text.isNotEmpty
                      ? taskController.taskCatController.text
                      : null,
                  items: categoryController.categories
                      .map((cat) => DropdownMenuItem(
                    value: cat.name,
                    child: Text(cat.name),
                  ))
                      .toList(),
                  onChanged: (selected) {
                    setState(() {
                      taskController.taskCatController.text = selected!;
                    });
                  },
                  menuMaxHeight: 200,
                ),
              );
            }),
            SizedBox(height: 16),
            Obx(() => SwitchListTile(
              title: Text('Send Alert Notifications', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              secondary: Icon(Icons.notifications_active, color: theme.colorScheme.primary),
              value: taskcontroller.haveNotify.value,
              onChanged: (val) => taskcontroller.haveNotify.value = val,
            )),

            ElevatedButton(
              onPressed: () async {
                taskController.taskTitle = taskController.taskNameController.text.trim();
                taskController.taskDesc = taskController.taskDescriptionController.text.trim();
                taskController.taskDate = selectedDateTime;
                taskController.year = year = selectedDateTime?.year;
                taskController.month = month = selectedDateTime?.month;
                taskController.day = day = selectedDateTime?.day;
                taskController.hour = hour = selectedDateTime?.hour;
                taskController.minute = minute = selectedDateTime?.minute;

                await taskController.addTaskWithNotification();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48), // ياخذ كامل العرض وارتفاع 48
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('Done'),
            ),

          ],
        ),
      ),
    );
  }

  Future<DateTime?> pickDateTime(BuildContext context, {DateTime? initialDate}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    final finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    print("✅ Picked DateTime: $finalDateTime");
    return finalDateTime;
  }
}
