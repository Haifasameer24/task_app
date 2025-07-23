import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../controller/task_controller.dart';
import '../models/tsks_model.dart';

class CategoryDetailPage extends StatelessWidget {
  final String catName;
  const CategoryDetailPage({required this.catName});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('$catName'),
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
                  Center(child: Text("لا توجد مهام حالياً"))
                else
                  ...tasks.map((task) => _buildTaskCard(task, context)).toList(),
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
              SnackBar(content: Text("تم حذف المهمة '${task.name}'")),
            );
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "حذف",
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
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Category: ${task.cat}",
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          "${task.dueDate.day} ${_getMonthName(task.dueDate.month)} ${task.dueDate.year} "
                              "${_formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${_getAmPm(task.dueDate.hour)}",
                          style:
                          TextStyle(fontSize: 13, color: subtitleColor),
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
