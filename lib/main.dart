import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/addCatgory_controller.dart';
import 'controller/them_controller.dart';
import 'firebase_options.dart';
import 'package:getx_course/screens/splash_screen.dart';
import 'package:getx_course/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await NotificationService.init();
  Get.put(ThemeController());
  Get.put(CategoryController());

  runApp(const MyApp());
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
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode:
        themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      );
    });
  }
}
