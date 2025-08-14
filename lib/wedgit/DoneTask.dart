import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import '../controller/addCatgory_controller.dart';
import '../controller/home_controller.dart';
import '../controller/task_controller.dart';
import '../models/Category.dart';
import '../models/tsks_model.dart';
class DoneTask extends StatelessWidget {
  final TaskController taskController = Get.find<TaskController>();
  final categoryController = Get.put(CategoryController());
  final HomeController homeController = Get.put(HomeController());
  final List<String> statusOption = ["inProgress"];
  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    final taskController = Get.find<TaskController>();
    final categoryController = Get.find<CategoryController>();

    final nameController = TextEditingController(text: task.name);
    final descriptionController = TextEditingController(text: task.description);
    final selectedCategory = RxString(task.cat);
    final haveNotify = RxBool(task.haveNotify);
    final selectedDateTime = Rx<DateTime>(task.dueDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // عشان يطلع فوق الكيبورد بشكل مناسب
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // نفس لون الخلفية للتناسق
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Task Name',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    filled: true,
                    fillColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final pickedDateTime = await pickDateTime(
                        context, initialDate: selectedDateTime.value);
                    if (pickedDateTime != null) {
                      selectedDateTime.value = pickedDateTime;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text: selectedDateTime.value
                            .toLocal()
                            .toString()
                            .substring(0, 16),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select Due Date & Time',
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Select Category',
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      filled: true,
                      fillColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: categoryController.categories
                        .map((e) => e.name)
                        .contains(selectedCategory.value)
                        ? selectedCategory.value
                        : null,
                    items: categoryController.categories
                        .map((cat) => DropdownMenuItem(
                      value: cat.name,
                      child: Text(cat.name),
                    ))
                        .toList(),
                    onChanged: (selected) {
                      if (selected != null) selectedCategory.value = selected;
                    },
                    menuMaxHeight: 200,
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Send Alert Notifications'),
                  value: haveNotify.value,
                  onChanged: (val) => haveNotify.value = val,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: Text("Save"),
                      onPressed: () async {
                        final updated = TaskModel(
                          id: task.id,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          dueDate: selectedDateTime.value,
                          status: task.status,
                          cat: selectedCategory.value,
                          haveNotify: haveNotify.value,
                          userId: task.userId,
                          createdAt: task.createdAt,
                        );


                        await taskController.updateTask(updated);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            )),
          ),
        );
      },
    );
  }

// دالة pickDateTime (لو عندك نسخة تقدر تستخدمها، لو لا خذ هذي)
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
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Obx(() {
        final seenIds = <String>{};
        final tasks = taskController.filteredTasks
            .where((task) => task.status == TaskStatus.done)
            .where((task) => seenIds.add(task.id)) // Remove duplicates
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Done Tasks',
                  style: GoogleFonts.inter(
                    fontSize: theme.textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            if (tasks.isEmpty)
              Center(child: Text(
                  'There is no task yet', style: theme.textTheme.bodyMedium))
            else
              ...tasks.map((task) => GestureDetector(
                  onTap: () {
                    final category = categoryController.categories.firstWhere(
                          (c) => c.name == task.cat,
                      orElse: () => Category(id: '', name: '', description: 'No description', color: Colors.grey),
                    );

                    showDialog(
                      context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HeroIcon(
                                  HeroIcons.document,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Task Details',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close", style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditTaskDialog(context, task);
                              },
                              child: const Text("Edit Task", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Task Name
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.clipboard, size: 18, color: Colors.green),
                                  SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Task Name: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: task.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Description
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HeroIcon(HeroIcons.clipboardDocument, size: 18, color: Colors.green),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Description: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: task.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Category
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.clipboardDocumentList, size: 18, color:Colors.green),
                                  SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Category: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: task.cat,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Category Description
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.clipboardDocumentList, size: 18, color:Colors.green),
                                  SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Cat. Description: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: category.description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Due Date
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.calendarDays, size: 18, color:Colors.green),
                                  SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Due Date: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${task.dueDate.day} ${taskController.getMonthName(task.dueDate.month)}, ${task.dueDate.year}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Time
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.clock, size: 18, color:Colors.green),
                                  SizedBox(width: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Time: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${taskController.formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${taskController.getAmPm(task.dueDate.hour)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Notification
                              Row(
                                children: [
                                  HeroIcon(HeroIcons.bellAlert, size: 18, color: Colors.green),
                                  SizedBox(width: 4),
                                  Obx(() => RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Notification: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                          text: taskController.haveNotify.value ? 'Enabled' : 'Disabled',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),

                            ],
                          ),
                        )
                    );
                  },
                  child: _buildTaskCard(task, context))).toList(),
          ],
        );
      }),
    );
  }

  Widget _buildTaskCard(TaskModel task, BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final subtitleColor = theme.hintColor;

    return Slidable(
      key: ValueKey('${task.id}_${task.createdAt.toIso8601String()}'),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () async {
            await taskController.deleteTask(task);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) async {
              await taskController.deleteTask(task);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "Delete",
          ),
        ],
      ),
      child: Stack(
        children: [
          // الكارد الأساسي
          Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Side colored box
                Container(
                  width: 50,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Icon(Icons.check_box_rounded, color: Colors.white),
                ),

                // Text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(fontSize: 13, color: subtitleColor,fontWeight: FontWeight.w600,),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Category: ${task.cat}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: categoryController.getColorByCategoryName(task.cat) ?? Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            HeroIcon(HeroIcons.clock, size: 18,color: Colors.green,),
                            SizedBox(width: 4),
                            Text(
                              "${task.dueDate.day} ${taskController.getMonthName(task.dueDate.month)} ${task.dueDate.year} "
                                  "${taskController.formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} "
                                  "${taskController.getAmPm(task.dueDate.hour)}",
                              style: TextStyle(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.w600,),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: subtitleColor),
                    onSelected: (String selected) async {
                      if (selected == "Change Status") {
                        bool changed = await taskController.changeTaskStatus(task, TaskStatus.inProgress);
                        if (!changed) {
                          Get.snackbar(
                            "Access Denied",
                            "Guests are not allowed to change task status.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: "Change Status",
                        child: Text("Mark as InProgress"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

}
