import 'package:get/get.dart';
import 'package:getx_course/app_routers.dart';
import 'package:getx_course/screens/home_screen.dart';
import 'package:getx_course/screens/login_screen.dart';
import 'package:getx_course/screens/signup_screen.dart';
import 'package:getx_course/screens/splash_screen.dart';

import 'controller/signup_controllr.dart';

class AppPages {
  static final routes = [
    GetPage(
        name: AppRoutes.splash,
        page: ()=> SplashScreen(),
    ),
    GetPage(
        name: AppRoutes.login,
        page: ()=> LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: ()=> SignupScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: ()=> HomeScreen(),
    ),
  ];
}