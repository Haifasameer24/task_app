import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/screens/signup_screen.dart';
import 'package:getx_course/screens/splash_screen.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../controller/profile_image_controller.dart';
import '../controller/task_controller.dart';
import '../controller/them_controller.dart';
import 'create_password.dart';
import 'edit_account_screen.dart';

class SettingsPage extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());
  final LoginController loginController = Get.put(LoginController());
  final ProfileImageController profileImageController = Get.put(ProfileImageController());
  final ThemeController themeController = Get.find<ThemeController>();

  SettingsPage({Key? key}) : super(key: key);
  Future<bool> isEmulator() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return !iosInfo.isPhysicalDevice;
    } else {
      return false;
    }
  }

  void _callPhoneNumber(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      Get.snackbar("خطأ", "تعذر فتح تطبيق الاتصال");
    }
  }



  void _showEditDialog(BuildContext context) {
    homeController.nameController.text = homeController.userName.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Obx(() {
              final imageUrl = profileImageController.photoUrl.value;
              final isUploading = profileImageController.isUploading.value;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/images/user_image.jpg') as ImageProvider,
                      ),
                      if (isUploading)
                        const CircularProgressIndicator(), // يظهر أثناء التحميل
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      await profileImageController.pickAndUploadImage();
                    },
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12,),
            TextField(
              controller: homeController.nameController,
              decoration: InputDecoration(
                hintText: 'Name User',
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await homeController.updateUserName(homeController.nameController.text);
              Navigator.pop(context);
            },

            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are You Sure To Logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // إغلاق الـ Dialog فقط
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.find<LoginController>().logout();
              Navigator.of(ctx).pop(); // إغلاق الـ Dialog بعد تسجيل الخروج
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile(BuildContext context, HeroIcons icon, String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      leading: HeroIcon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      trailing: HeroIcon(HeroIcons.chevronRight, size: 18, color: Theme.of(context).colorScheme.primary),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskcontroller = Get.put(TaskController());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
        children: [
          // Profile Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(() {
                        final imageUrl = profileImageController.photoUrl.value;
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const AssetImage('assets/images/user_image.jpg') as ImageProvider,
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCircleButton(context, HeroIcons.pencilSquare, () {
                          final box = GetStorage();
                          bool isGuest = box.read("is_guest") ?? false;

                          if (isGuest) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: const Text("signup to edite your profile"),
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
                          } else
                            _showEditDialog(context);
                        },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Text(
                    homeController.userName.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )),
                  const SizedBox(height: 6),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Settings Section
          _buildSettingCard(context, [
            Obx(() => SwitchListTile(
              title: Text('Notifications', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              secondary: HeroIcon(HeroIcons.bellAlert, color: theme.colorScheme.primary),
              value: taskcontroller.isNotificationOn.value,
              onChanged: (val) => taskcontroller.isNotificationOn.value = val,
            )),
            const SizedBox(height: 10),
            Obx(() => SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              secondary: HeroIcon(HeroIcons.moon, color: theme.colorScheme.primary),
              value: themeController.isDarkMode.value,
              onChanged: (val) => themeController.toggleTheme(val),
            )),
          ]),

          const SizedBox(height: 20),

          // Info Section
          _buildSettingCard(context, [
    _buildTile(context, HeroIcons.user, 'Account', () async {
    final box = GetStorage();
    final isGuest = box.read("is_guest") ?? false;

    if (isGuest) {
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    content: const Text("Signup to edit your profile"),
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
    return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
    Get.snackbar("خطأ", "لم يتم تسجيل الدخول بشكل صحيح");
    return;
    }

    await user.reload();

    // جلب مزودي الدخول للحساب
    final providerIds = user.providerData.map((p) => p.providerId).toList();

    print("User providers: $providerIds"); // طباعة للتأكد أثناء التطوير

    final hasGoogle = providerIds.contains('google.com');
    final hasPassword = providerIds.contains('password');

    if (hasGoogle && !hasPassword) {
    // عنده Google بس بدون كلمة مرور
    Get.to(() => CreatePasswordScreen(email: user.email!));
    } else {
    // عنده باسورد (سواء كان جوجل أو غيره)
    Get.to(() => const PasswordScreen());
    }
    }, isDark),

    _buildTile(context, HeroIcons.questionMarkCircle, 'Help & Support', () {
    showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
    return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
    height: 150,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Help & Support',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 20),
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    const Text(
    'Contact us at: ',
    style: TextStyle(fontSize: 16),
    ),
    InkWell(
      onTap: () async {
        bool emulator = await isEmulator();
        print("Is emulator? $emulator");

        if (emulator) {
          Navigator.of(context).pop(); // إغلاق الـ BottomSheet
          await Future.delayed(const Duration(milliseconds: 300));
          Get.snackbar(
            "تنبيه",
            "لا يمكن فتح الاتصال على المحاكي، الرجاء نسخ الرقم والاتصال من هاتف حقيقي",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        } else {
          _callPhoneNumber('+9720598882344');
        }
      },

      child: const SelectableText(
    '+9720598882344',
    style: TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 16,
    ),
    ),
    ),
    ],
    ),
    const Spacer(),
    Align(
    alignment: Alignment.bottomRight,
    child: TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: const Text('Close'),
    ),
    ),
    ],
    ),
    ),
    );
    },
    );
    }, isDark),





    _buildTile(context, HeroIcons.phone, 'Contact us', () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact us',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Contact us at: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              InkWell(
                                onTap: () => _callPhoneNumber('+9720598882344'),
                                child: const Text(
                                  '+9720598882344',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }, isDark),

            _buildTile(context, HeroIcons.informationCircle, 'About App', () {}, isDark),
            _buildTile(context, HeroIcons.arrowLeftStartOnRectangle, 'Log out', () {
              final isGuest = GetStorage().read("is_guest") ?? false;
              if (isGuest) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text("Signup to Save your Tasks"),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              content: const Text("Signup to save your tasks"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    Get.to(() => SignupScreen());
                                  },
                                  child: const Text("Sign up"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final box = GetStorage();
                                    FirebaseAuth.instance.signOut();
                                    box.erase();
                                    Get.offAll(() => SplashScreen());
                                  },
                                  child: const Text("Logout"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                );
              }
              else {
                _showLogoutDialog(context);
              }
            }, isDark),

          ]),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
Widget _buildCircleButton(BuildContext context, HeroIcons icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: HeroIcon(icon, size: 18, color: Colors.white),
    ),
  );
}
