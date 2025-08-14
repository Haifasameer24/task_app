import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controller/addCatgory_controller.dart';
import 'controller/them_controller.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة التخزين
  await GetStorage.init();

  // وضع الكنترولرز
  Get.put(ThemeController());
  Get.put(CategoryController());

  runApp(const MyApp());
  // تشغيل الإشعارات بعد تشغيل الواجهة
  Future.delayed(const Duration(seconds: 2), () async {
    await NotificationService.init();
  });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() {
      return GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme:ThemeData.dark(),
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const SplashScreen(),
      );
    });
  }
}
