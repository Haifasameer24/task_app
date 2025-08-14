import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';
import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';
import '../models/Category.dart';

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
                   taskcontroller.setDateTime(pickedDateTime);
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
                return Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Category"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Add Category"),
                            content: const Text("Do you want to add a new category?"),
                            actions: [
                              // خيار لا ➜ إضافة كاتيجوري افتراضية
                              TextButton(
                                onPressed: (){
                                   categoryController.addCategoryDirect(
                                    "Default Category",
                                    "Default category",
                                    Colors.blue,
                                  );
                                  Get.back();
                                },
                                child: const Text("No"),
                              ),
                              // خيار نعم ➜ عرض واجهة الإضافة
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (context) {
                                      // نفس كود addCard اللي عندك
                                      Color? selectedColor;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 24,
                                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                                        ),
                                        child: StatefulBuilder(
                                          builder: (context, setModalState) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: categoryController.CatnameController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Category Name',
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
                                                TextField(
                                                  controller: categoryController.CatdescController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Category Description',
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
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Select Color', style: Theme.of(context).textTheme.bodyLarge),
                                                ),
                                                SizedBox(height: 8),
                                                Wrap(
                                                  spacing: 8,
                                                  children: [
                                                    Colors.red,
                                                    Colors.green,
                                                    Colors.blue,
                                                    Colors.orange,
                                                    Colors.purple,
                                                    Colors.teal
                                                  ].map((color) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setModalState(() {
                                                          selectedColor = color;
                                                          categoryController.selectedColor = color;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration: BoxDecoration(
                                                          color: color,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: selectedColor == color
                                                                ? Theme.of(context).colorScheme.primary
                                                                : Colors.transparent,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await categoryController.addCategory(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    minimumSize: const Size(double.infinity, 48),
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
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              }

              // لو فيه كاتيجوري ➜ Dropdown عادي
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
                  value: (taskController.taskCatController.text.isNotEmpty &&
                      categoryController.categories
                          .where((c) => c.name == taskController.taskCatController.text)
                          .length == 1)
                      ? taskController.taskCatController.text
                      : null,

                  items: categoryController.categories
                      .map((cat) => DropdownMenuItem(
                    value: cat.name,
                    child: Text(cat.name),
                  ))
                      .toList(),
                  onChanged: (selected) {
                    taskController.taskCatController.text = selected!;
                  },
                  menuMaxHeight: 200,
                ),
              );
            }),

            SizedBox(height: 16),
            Obx(() => SwitchListTile(
              title: Text('Send Alert Notifications', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              secondary: HeroIcon(HeroIcons.bellAlert, color: theme.colorScheme.primary),
              value: taskcontroller.haveNotify.value,
              onChanged: (val) => taskcontroller.haveNotify.value = val,
            )),

            ElevatedButton(
              onPressed: () async {
                print('Button pressed');
                await taskController.prepareAndSaveTask(selectedDateTime);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
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
