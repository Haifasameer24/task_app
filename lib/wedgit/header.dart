import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/addCatgory_controller.dart';
import '../controller/task_controller.dart';

enum SearchFilter { tasks, categories }

class HeaderWidget extends StatefulWidget {
  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final TaskController taskController = Get.find<TaskController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  final Rx<SearchFilter> searchFilter = SearchFilter.tasks.obs;

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Filter by",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            RadioListTile<SearchFilter>(
              title: const Text('Tasks'),
              value: SearchFilter.tasks,
              groupValue: searchFilter.value,
              onChanged: (SearchFilter? selected) {
                if (selected != null) {
                  searchFilter.value = selected;
                  taskController.searchText.value = '';
                  categoryController.searchText.value = '';
                }
              },
            ),
            RadioListTile<SearchFilter>(
              title: const Text('Categories'),
              value: SearchFilter.categories,
              groupValue: searchFilter.value,
              onChanged: (SearchFilter? selected) {
                if (selected != null) {
                  searchFilter.value = selected;
                  taskController.searchText.value = '';
                  categoryController.searchText.value = '';
                }
              },
            ),
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = 48; // ارتفاع موحد

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: fieldHeight,
              child: TextField(
                onChanged: (value) {
                  if (searchFilter.value == SearchFilter.tasks) {
                    taskController.searchText.value = value;
                    categoryController.searchText.value = '';
                  } else {
                    categoryController.searchText.value = value;
                    taskController.searchText.value = '';
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.black.withOpacity(0.6)),
                  hintText: searchFilter.value == SearchFilter.tasks
                      ? "Search Tasks"
                      : "Search Categories",
                  filled: true,
                  fillColor: Colors.grey[300],
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: fieldHeight,
            width: fieldHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showFilterBottomSheet,
              child: Icon(Icons.filter_alt_outlined, color: Colors.black.withOpacity(0.6)),
            ),
          ),
        ],
      )),
    );
  }
}
