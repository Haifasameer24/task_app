import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';

import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';
import '../models/Category.dart';
import '../models/tsks_model.dart';
import '../wedgit/edit_form.dart';
class CategoryDetailPage extends StatelessWidget {
  final String catName;
   CategoryDetailPage({required this.catName});
  final categoryController = Get.put(CategoryController());
//////////////
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
                        taskController.haveNotify.value = haveNotify.value;
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
////////////////////////////////
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
  void _confirmDeleteCategoryTasks(
      BuildContext context,
      Category category,
      CategoryController categoryController,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete"),
        content: Text("Are You sure you want to delete category and task؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // إلغاء
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              categoryController.deleteCategoryAndTasks(category); // نمرر الكائن مباشرة
              Get.back();
              Get.back();
            },
            child: Text(
              "Delete Category",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final CategoryController categoryController = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('$catName'),
          actions: [  PopupMenuButton<String>(
            onSelected: (value) {
              final categoryController = Get.find<CategoryController>();
              final category = categoryController.categories.firstWhere((c) => c.name == catName);

              if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => CategoryForm(category: category),
                );
              } else if (value == 'delete') {
                _confirmDeleteCategoryTasks(context, category, categoryController);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    HeroIcon(HeroIcons.pencilSquare, color: Colors.grey, size: 24),
                    Text('Edite Category'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    HeroIcon(HeroIcons.trash, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text('Delete Category', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          )]



      ),

      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Obx(() {
            final seenIds = <String>{};
            final tasks = taskController.tasks
                .where((task) => task.cat == catName)
                .where((task) => seenIds.add(task.id))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                if (tasks.isEmpty)
                  Center(child: Text("No tasks yet"))
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
                                color:_getStatusColor(task.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const HeroIcon(
                                    HeroIcons.clipboardDocument,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      'Task Details',
                                      style:TextStyle(
                                          color:Colors.white,
                                          fontSize: 18
                                      )
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
                                  backgroundColor:_getStatusColor(task.status),
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
                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.clipboard, size: 18,color:_getStatusColor(task.status),),
                                    SizedBox(width: 4),
                                    Text('Task Name: ${task.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],

                                      ),),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start, // مهم عشان النص يصف من الأعلى
                                  children: [
                                    HeroIcon(
                                      HeroIcons.clipboardDocument,
                                      size: 18,
                                      color: _getStatusColor(task.status),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded( // مهم جداً عشان يسمح للنص ياخد عرض كافي ويتلف للسطر الثاني
                                      child: Text(
                                        'Description: ${task.description}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                        softWrap: true, // يلف النص تلقائيًا
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.clipboardDocumentList, size: 18,color: _getStatusColor(task.status),),
                                    SizedBox(width: 4),
                                    Text(' Category ${task.cat}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],

                                      ),),
                                  ],
                                ),


                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.clipboardDocumentList, size: 18,color: _getStatusColor(task.status)),
                                    SizedBox(width: 4),
                                    Text('Cat. Description ${category.description}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],

                                      ),),
                                  ],
                                ),



                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.calendarDays, size: 18,color:_getStatusColor(task.status),),
                                    SizedBox(width: 4),
                                    Text(
                                      'Due Date ${task.dueDate.day} ${taskController.getMonthName(task.dueDate.month)}, ${task.dueDate.year}'
                                      ,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.clock, size: 18,color: _getStatusColor(task.status),),
                                    SizedBox(width: 4),
                                    Text(
                                      'Time ${taskController.formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${taskController.getAmPm(task.dueDate.hour)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),),
                                  ],
                                ),


                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    HeroIcon(HeroIcons.bellAlert, size: 18,color: _getStatusColor(task.status),),
                                    SizedBox(width: 4),
                                    Obx(() => Text(
                                      'Notification ${taskController.haveNotify.value ? 'Enabled' : 'Disabled'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),),)
                                  ],
                                ),




                              ],
                            ),
                          ),
                        );
                      },
                      child: _buildTaskCard(task, context))).toList(),
              ],
            );
          }),
        ),
      ),
    );
  }


  Widget _buildTaskCard(TaskModel task, BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
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
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId == null) {
              Get.snackbar("خطأ", "المستخدم غير مسجل الدخول");
              return;
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('tasks')
                .doc(task.id)
                .delete();

            taskController.tasks.remove(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Deleted task '${task.name}'")),
            );
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "Delete",
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // الشريط الجانبي حسب الحالة
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: _getStatusColor(task.status),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(Icons.assignment, color: Colors.white),
            ),


            // النصوص
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(fontSize: 13, color: subtitleColor,fontWeight: FontWeight.w600,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Category: ${task.cat}",
                      style: TextStyle(
                        fontSize: 13,
                        color:  categoryController.getColorByCategoryName(task.cat) ?? Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            HeroIcon(HeroIcons.clock,size: 15,),
                            SizedBox(width: 4,),
                            Text(
                              "${task.dueDate.day} ${_getMonthName(task.dueDate.month)} ${task.dueDate.year} "
                                  "${_formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${_getAmPm(task.dueDate.hour)}",
                              style: TextStyle(fontSize: 13, color: subtitleColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // حالة المهمة
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:_getStatusLabelColor(task.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(task.status).toUpperCase(),
                  style:  TextStyle(
                    fontSize: 12,
                    color:_textLabalColor(task.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.upcoming:
        return "Upcoming";
      case TaskStatus.inProgress:
        return "In Progress";
      case TaskStatus.done:
        return "Done";
      default:
        return "Unknown";
    }
  }
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.upcoming:
        return Color(0xFF4B3FAF); // اللون للحالة Upcoming
      case TaskStatus.inProgress:
        return Colors.orange;   // اللون للحالة In Progress
      case TaskStatus.done:
        return Colors.green;  // اللون للحالة Done
      default:
        return Colors.grey;
    }
  }
  Color _getStatusLabelColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.upcoming:
        return Color(0xFF4B3FAF).withOpacity(0.3);
      case TaskStatus.inProgress:
        return Colors.orange.withOpacity(0.3);
      case TaskStatus.done:
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }
  Color _textLabalColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.upcoming:
        return Color(0xFF4B3FAF);
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }

  String _getAmPm(int hour) {
    return hour >= 12 ? "PM" : "AM";
  }

  String _formatHour(int hour) {
    final formatted = hour % 12 == 0 ? 12 : hour % 12;
    return formatted.toString().padLeft(2, '0');
  }
}
