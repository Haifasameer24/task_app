import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/screens/signup_screen.dart';
import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';
import '../models/tsks_model.dart';

class UpComingTasks extends StatelessWidget {
  final TaskController taskController = Get.find<TaskController>();
  final categoryController = Get.put(CategoryController());

  final List<String> statusOption = ["inProgress"];


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Obx(() {
        final seenIds = <String>{};
        final tasks = taskController.filteredTasks
            .where((task) => task.status == TaskStatus.upcoming)
            .where((task) => seenIds.add(task.id)) // Remove duplicates
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Tasks',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("'Task Deleted'${task.name}'")),
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
            Container(
              width: 50,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF4B3FAF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(Icons.assignment, color: Colors.white),
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
                        color: categoryController.getColorByCategoryName(task.cat) ?? Colors.orange,
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
                      final box = GetStorage();
                      bool isGuest = box.read("is_guest") ?? false;
                      if (isGuest) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text("Signup to Change Task Status"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Get.to(() => SignupScreen());
                                },
                                child: const Text("Sign up"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      }  else {
                      await taskController.changeTaskStatus(task,TaskStatus.inProgress);
                      }
                    }
                  },

                  itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: "Change Status",
                    child: Text("Mark as In Progress"),
                  ),
                ],
              ),
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
