import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/models/tsks_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';

import '../controller/addCatgory_controller.dart';
import '../models/Category.dart';
class AllTasksPage extends StatelessWidget {
   AllTasksPage({super.key});
  final categoryController = Get.put(CategoryController());
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
    final TaskController taskController = Get.find<TaskController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final seenIds = <String>{};
          final tasks = taskController.tasks
              .where((task) => seenIds.add(task.id))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Tasks',
                  style: GoogleFonts.inter(
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text("No Tasks yest"))
                      : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) =>
                        _buildTaskCard(tasks[index], context),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

   Widget _buildTaskCard(TaskModel task, BuildContext context) {
     final TaskController taskController = Get.find<TaskController>();
     final CategoryController categoryController = Get.find<CategoryController>();
     final theme = Theme.of(context);
     final cardColor = theme.cardColor;
     final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
     final subtitleColor = theme.hintColor;

     return Slidable(
       key: ValueKey('${task.id}_${task.createdAt.toIso8601String()}'),
       endActionPane: ActionPane(
         motion: const ScrollMotion(),
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
               SnackBar(content: Text("Task Deleted '${task.name}'")),
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
               offset: const Offset(0, 4),
             ),
           ],
         ),
         child: GestureDetector(
           onTap: () {
             final category = categoryController.categories.firstWhere(
                   (c) => c.name == task.cat,
               orElse: () => Category(
                 id: '',
                 name: '',
                 description: 'لا يوجد وصف',
                 color: Colors.grey,
               ),
             );

             showDialog(
               context: context,
               builder: (context) => AlertDialog(
                 backgroundColor: theme.colorScheme.surface,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16),
                 ),
                 title: Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: _getStatusColor(task.status),
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
                       const Text(
                         'Task Details',
                         style: TextStyle(color: Colors.white, fontSize: 18),
                       ),
                     ],
                   ),
                 ),
                 content: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         HeroIcon(HeroIcons.clipboard,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Text(
                           'Task Name: ${task.name}',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Colors.grey[700],
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         HeroIcon(HeroIcons.clipboardDocument,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Expanded(
                           child: Text(
                             'Description: ${task.description}',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               color: Colors.grey[700],
                             ),
                             softWrap: true,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         HeroIcon(HeroIcons.clipboardDocumentList,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Text(
                           'cat: ${task.cat}',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Colors.grey[700],
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         HeroIcon(HeroIcons.clipboardDocumentList,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Text(
                           'Cat.Description: ${category.description}',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Colors.grey[700],
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         HeroIcon(HeroIcons.calendarDays,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Text(
                           'Date: ${task.dueDate.day} ${taskController.getMonthName(task.dueDate.month)}, ${task.dueDate.year}',
                           style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
                             color: Colors.grey[700],
                           ),
                         ),
                       ],
                     ),
                     Row(
                       children: [
                         HeroIcon(HeroIcons.clock,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Text(
                           'Time: ${taskController.formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${taskController.getAmPm(task.dueDate.hour)}',
                           style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
                             color: Colors.grey[700],
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         HeroIcon(HeroIcons.bellAlert,
                             size: 18, color: _getStatusColor(task.status)),
                         const SizedBox(width: 4),
                         Obx(
                               () => Text(
                             'notification ${taskController.haveNotify.value ? 'Enable' : 'Disable'}',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               color: Colors.grey[700],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
                 actions: [
                   TextButton(
                     style: TextButton.styleFrom(
                       backgroundColor: Colors.grey.shade200,
                       padding:
                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10)),
                     ),
                     onPressed: () => Navigator.pop(context),
                     child: const Text("Close", style: TextStyle(color: Colors.black)),
                   ),
                   TextButton(
                     style: TextButton.styleFrom(
                       backgroundColor: _getStatusColor(task.status),
                       padding:
                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10)),
                     ),
                     onPressed: () {
                       Navigator.pop(context);
                       _showEditTaskDialog(context, task);
                     },
                     child: const Text("Edit Task", style: TextStyle(color: Colors.white)),
                   ),
                 ],
               ),
             );
           },
           child: Row(
             children: [
               // الشريط الجانبي حسب الحالة
               Container(
                 width: 50,
                 height: 120,
                 decoration: BoxDecoration(
                   color: _getStatusColor(task.status),
                   borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(16),
                     bottomLeft: Radius.circular(16),
                   ),
                 ),
                 child: const Icon(
                   Icons.assignment,
                   color: Colors.white,
                 ),
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
                         style: TextStyle(
                           fontSize: 13,
                           color: subtitleColor,
                           fontWeight: FontWeight.w600,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 4),
                       Text(
                         "Catogroy: ${task.cat}",
                         style: TextStyle(
                           fontSize: 13,
                           color: categoryController.getColorByCategoryName(task.cat) ?? Colors.grey,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           const SizedBox(width: 6),
                           Row(
                             children: [
                                HeroIcon(HeroIcons.clock, size: 18, color: _getStatusColor(task.status)),
                               const SizedBox(width: 4),
                               Text(
                                 "${task.dueDate.day} ${taskController.getMonthName(task.dueDate.month)} ${task.dueDate.year} "
                                     "${taskController.formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${taskController.getAmPm(task.dueDate.hour)}",
                                 style: TextStyle(fontSize: 13, color: subtitleColor),
                               ),
                             ],
                           ),
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
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: _getStatusLabelColor(task.status),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     _getStatusText(task.status).toUpperCase(),
                     style: TextStyle(
                       fontSize: 12,
                       color: _getTextColor(task.status),
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ),
             ],
           ),
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
        return Colors.grey;
    }
  }
  Color _getTextColor(TaskStatus status){
    switch (status){
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
}
