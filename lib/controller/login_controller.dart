import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx_course/controller/task_controller.dart';
import 'package:getx_course/screens/home_screen.dart';
import 'package:getx_course/screens/splash_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController email = TextEditingController();
  final box = GetStorage();
  final isLoading = false.obs;
  final isLoadingguest = false.obs;
  final isSignup = false.obs;
  final isGoogle = false.obs;
  var userEmail = ''.obs;

  // لإنشاء كائن GoogleSignIn مع النطاقات المطلوبة
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> login() async {
    isLoading.value = true;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      await _setUserLoggedIn();
      Get.put(TaskController());
      userEmail.value = FirebaseAuth.instance.currentUser?.email ?? "";
      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("Error", "Because ${e.toString()}");
    }
    isLoading.value = false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await box.remove("id");
    await box.remove("name");
    await box.remove("email");
    await box.remove("create_date");
    await box.remove("photoUrl");
    await box.write("is_logged_in", false);
    await box.write("is_guest", false);
    Get.offAll(SplashScreen());
  }

  Future<void> _setUserLoggedIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      DocumentReference userRef = _firestore.collection("users").doc(uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        await box.write("id", uid);
        await box.write("name", userData["name"]);
        await box.write("email", userData["email"]);
        await box.write("create_date", userData["createdAt"]);
        await box.write("photoUrl", userData["photoUrl"] ?? '');
      }
      await box.write("is_logged_in", true);
      box.write("seen_onboarding", true);
    }
  }

  String generateGuestName() {
    final randomNumber = DateTime
        .now()
        .millisecondsSinceEpoch
        .remainder(10000);
    return "Guest_$randomNumber";
  }

  Future<void> signInAsGuest() async {
    isLoadingguest.value = true;
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      if (auth.currentUser == null) {
        UserCredential result = await auth.signInAnonymously();
        final user = result.user;
        final docRef = firestore.collection('users').doc(user!.uid);
        final doc = await docRef.get();

        final guestName = generateGuestName();

        if (!doc.exists) {
          await docRef.set({
            "uid": user.uid,
            "name": guestName,
            "email": "",
            "createdAt": DateTime.now().toIso8601String(),
          });
        }

        await box.write("id", user.uid);
        await box.write("name", guestName);
        await box.write("email", "");
        await box.write("create_date", DateTime.now().toIso8601String());
        await box.write("is_logged_in", true);
        await box.write("is_guest", true);
        box.write("seen_onboarding", true);

        Get.put(TaskController());
        Get.offAll(HomeScreen());
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل تسجيل المستخدم الضيف: ${e.toString()}");
    } finally {
      isLoadingguest.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isGoogle.value = true;
    print("Starting Google sign-in...");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("Google user: $googleUser");
      if (googleUser == null) {
        print("User cancelled Google sign-in.");
        isGoogle.value = false;
        return; // المستخدم ألغى تسجيل الدخول
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      print("Google authentication tokens received.");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Credential created.");

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      print("Firebase sign-in successful.");

      final user = userCredential.user;
      print("Signed in user: $user");

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(
            user.uid);
        final doc = await userRef.get();
        print("Checking if user document exists in Firestore.");

        if (!doc.exists) {
          print("User document does not exist. Creating...");
          await userRef.set({
            'uid': user.uid,
            'name': user.displayName ?? 'Google User',
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
            'createdAt': DateTime.now().toIso8601String(),
          });
          print("User document created.");
        } else {
          print("User document exists. Updating...");
          await userRef.update({
            'name': user.displayName ?? 'Google User',
            'email': user.email ?? '',
            'photoUrl': user.photoURL ?? '',
          });
          print("User document updated.");
        }

        print("Writing user data to local storage.");
        await box.write("id", user.uid);
        await box.write("name", user.displayName ?? 'Google User');
        await box.write("email", user.email ?? '');
        await box.write("photoUrl", user.photoURL ?? '');
        await box.write("create_date", DateTime.now().toIso8601String());
        await box.write("is_logged_in", true);
        await box.write("is_guest", false);
        box.write("seen_onboarding", true);
        print("Local storage updated.");

        Get.put(TaskController());
        print("TaskController initialized.");

        Get.offAll(HomeScreen());
        print("Navigated to HomeScreen.");
      }
    } catch (e, stacktrace) {
      print("Error during Google sign-in: $e");
      print("Stacktrace: $stacktrace");
      Get.snackbar("Error", "Failed to sign in with Google: ${e.toString()}");
    } finally {
      isLoading.value = false;
      print("Google sign-in process ended. isLoading set to false.");
    }
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // دالة لإعادة المصادقة (Re-authenticate) - ضرورية قبل تغيير الايميل أو الباسورد
  Future<UserCredential> _reauthenticate(String currentEmail, String currentPassword) async {
    final credential = EmailAuthProvider.credential(email: currentEmail, password: currentPassword);
    return await _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  // دالة تغيير الايميل والباسورد (الباسورد اختياري)
  Future<String> updateEmailAndPassword({
    required String currentEmail,
    required String currentPassword,
    required String newEmail,
    String? newPassword,
  }) async {
    try {
      // أولاً إعادة المصادقة
      await _reauthenticate(currentEmail, currentPassword);

      // تغيير الايميل
      await _auth.currentUser!.updateEmail(newEmail);

      // لو تم تمرير باسورد جديد، نغيره
      if (newPassword != null && newPassword.isNotEmpty) {
        await _auth.currentUser!.updatePassword(newPassword);
      }

      // إعادة تسجيل الدخول بالإيميل الجديد (مهم جداً حتى يبقى المستخدم مسجل دخول)
      await _auth.signInWithEmailAndPassword(email: newEmail, password: newPassword ?? currentPassword);

      return "Email and password updated successfully.";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to update email or password.";
    } catch (e) {
      return "An error occurred: $e";
    }
  }


}


