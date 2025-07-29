import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileImageController extends GetxController {
  var photoUrl = ''.obs;
  var isUploading = false.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> loadProfileImage() async {
    if (currentUserId.isEmpty) return;
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    photoUrl.value = doc.data()?['photoUrl'] ?? '';
  }

  Future<void> pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    isUploading.value = true; // بدأ الرفع

    try {
      final file = File(pickedFile.path);
      final newRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$currentUserId.jpg');

      if (photoUrl.value.isNotEmpty) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(photoUrl.value);
          await oldRef.delete();
        } catch (e) {
          print('Error when delete image $e');
        }
      }

      await newRef.putFile(file);
      final newUrl = await newRef.getDownloadURL();

      photoUrl.value = newUrl;
      await _firestore.collection('users').doc(currentUserId).update({
        'photoUrl': newUrl,
      });
    } finally {
      isUploading.value = false; // انتهى الرفع
    }
  }
}
