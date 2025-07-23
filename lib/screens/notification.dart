import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/models/tsks_model.dart';

import '../controller/addCatgory_controller.dart';

class NotificationPage extends StatelessWidget{
  final TaskController taskController = Get.find<TaskController>();
  final categoryController = Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Obx(() {
          final seenIds = <String>{};
          final tasks = taskController.filteredTasks
              .where((task) => task.haveNotify == true)
              .where((task) => seenIds.add(task.id)) // Remove duplicates
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: "RobotoSlab",
                ),
              ),
              SizedBox(height: 20),
              if (tasks.isEmpty)
                Center(child: Text('There is no task yet', style: theme.textTheme.bodyMedium))
              else
                ...tasks.map((task) => _buildTaskCard(task, context)).toList(),
            ],
          );
        }),
      ),
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
            final userId = GetStorage().read("id");
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('tasks')
                .doc(task.id)
                .delete();
            taskController.tasks.remove(task);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('tasks')
                  .doc(task.id)
                  .delete();
              taskController.tasks.remove(task);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("'Notification Deleted'${task.name}'")),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "Delete",
          ),
        ],
      ),
      child: Container(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF4B3FAF),
                  borderRadius: BorderRadius.all(Radius.circular(50)),

                ),
                child: Icon(Icons.assignment, color: Colors.white),
              ),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: task.description,
                            style: TextStyle(fontSize: 13, color: subtitleColor),
                          ),
                          TextSpan(
                            text: ' ( ${task.cat}) ',
                            style: TextStyle(
                              fontSize: 13,
                              color: categoryController.getColorByCategoryName(task.cat) ?? Colors.grey, // لون مخصص للفئة
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.alarm_add_outlined,size: 13,),
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
              ),
            ),

           // Notification
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.notifications_on_outlined, color: subtitleColor,size: 20,),
              ),
          ],
        ),
      ),
    );
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
