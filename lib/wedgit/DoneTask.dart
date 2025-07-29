import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';
import '../models/tsks_model.dart';

class DoneTask extends StatelessWidget {
  final box = GetStorage();
  final TaskController taskController = Get.find<TaskController>();
  final categoryController1 = Get.put(CategoryController());
  final List<String> statusOptions = ["done"];

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Obx(() {
        final seenIds = <String>{};
        final tasks = taskController.filteredTasks
            .where((task) => task.status == TaskStatus.done)
            .where((task) => seenIds.add(task.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Done Tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "RobotoSlab",
              ),
            ),
            SizedBox(height: 20),
            if (tasks.isEmpty)
              Center(child: Text("There is no task yet", style: theme.textTheme.bodyMedium))
            else
              ...tasks.map((task) => _buildTaskCard(task, context, statusOptions, taskController,categoryController1,)).toList(),
          ],
        );
      }),
    );
  }
}

Widget _buildTaskCard(
    TaskModel task,
    BuildContext context,
    List<String> statusOptions,
    TaskController taskController,
    CategoryController categoryController,
    ) {
  final theme = Theme.of(context);
  final cardColor = theme.cardColor;
  final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
  final subtitleColor = theme.hintColor;
  return Slidable(
    key: ValueKey(task.id),
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
          // Side icon box
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Category: ${task.cat}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: categoryController.getColorByCategoryName(task.cat) ?? Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${task.dueDate.day} ${_getMonthName(task.dueDate.month)} ${task.dueDate.year} "
                        "${_formatHour(task.dueDate.hour)}:${task.dueDate.minute.toString().padLeft(2, '0')} ${_getAmPm(task.dueDate.hour)}",
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
            ),
          ),

          // Menu
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
  );
}

// Helper functions
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
