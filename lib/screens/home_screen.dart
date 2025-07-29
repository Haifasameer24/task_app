import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/addCatgory_controller.dart';
import '../controller/home_controller.dart';
import '../controller/profile_image_controller.dart';
import '../controller/task_controller.dart';
import '../screens/setting_screen.dart';
import '../wedgit/DoneTask.dart';
import '../wedgit/add_wedgit.dart';
import '../wedgit/inProgress.dart';
import '../wedgit/upcoming.dart';
import '../wedgit/categoties.dart';
import 'all_task.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final profialImageController=Get.put(ProfileImageController());
  final taskController = Get.put(TaskController());
  final categoryController = Get.put(CategoryController());
  final HomeController controller = Get.put(HomeController());
  final GetStorage box = GetStorage();

  int _selectedIndex = 0;
  String filterMode = "Tasks";

  List<Widget> getPages() {
    return [
      // index 0 → Home
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${controller.userName.value}!",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Have a nice day!",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                 child: Obx((){
                   final imageUrl=profialImageController.photoUrl.value;
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(30),
                     child: imageUrl.isNotEmpty
                         ? Image.network(imageUrl, width: 44, height: 44, fit: BoxFit.cover)
                         : Image.asset('assets/images/user_image.jpg', width: 44, height: 44, fit: BoxFit.cover),
                   );
                 }),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      if (filterMode == "Tasks") {
                        taskController.searchText.value = value;
                      } else {
                        categoryController.searchText.value = value;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: filterMode == "Tasks" ? 'Search tasks...' : 'Search categories...',
                      prefixIcon: Icon(Icons.search),
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
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _showFilterDialog(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListCatigroies(),
            SizedBox(height: 20),
            UpComingTasks(),
            InProgress(),
            DoneTask(),
          ],
        ),
      ),

      AllTasksPage(),

      // index 1 → Notifications
      NotificationPage(),



      // index 2 → Settings
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: getPages()[_selectedIndex]),
      bottomNavigationBar: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(icon: Icons.home_rounded, index: 0),
            _buildTabItem(icon: Icons.list_alt_rounded, index: 1), // ← يستدعي صفحة AllTasks
            _buildAddButton(primaryColor),
            _buildTabItem(icon: Icons.notifications_none, index: 2),
            _buildTabItem(icon: Icons.settings_rounded, index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => AddButton(),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? primaryColor : Theme.of(context).iconTheme.color?.withOpacity(0.6),
      ),
    );
  }

  // ← هذا فقط يفتح صفحة خارجية عند الضغط
  Widget _buildExternalTab({required IconData icon, required Widget target}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => Get.to(() => target),
      child: Icon(
        icon,
        size: 24,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Filter', style: Theme.of(context).textTheme.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Tasks'),
              onTap: () {
                setState(() {
                  filterMode = "Tasks";
                });
                Get.back();
              },
            ),
            ListTile(
              title: Text('Categories'),
              onTap: () {
                setState(() {
                  filterMode = "Categories";
                });
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
