import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';


  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    if(_storage.hasData(_key)){
      isDarkMode.value=_storage.read(_key);
    }else{
      // If not found, get from system setting
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
      saveThemeToStorage(isDarkMode.value);
    }
    // Apply theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void saveThemeToStorage(bool isDarkMode) => _storage.write(_key, isDarkMode);

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    saveThemeToStorage(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
