import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService extends GetxController{
  static FirebaseStorageService get instance => Get.find();

  final _firebaseStorage =  FirebaseStorage.instance;

  /// Upload Local assets from IDE
  /// Return a Uint8List containing image data
  Future<Uint8List> getImageDataFromAssets(String path) async {
    try{
      final byteData = await rootBundle.load(path);
      final imageData = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      return imageData;
    } catch (e) {
      throw 'Something loading image data: $e';
    }
  }
  /// Upload Image using ImageData on cloud FireBase FireStore
  /// Return a Uint8List containing image data
  Future<String> uploadImageData(String path, Uint8List image, String name) async {
    try {
      final ref = _firebaseStorage.ref(path).child(name);
      await ref.putData(image);
      final url = await ref.getDownloadURL();
      return url;
    }   catch (e) {
      throw 'Something loading image data: $e';
    }
  }

  /// Upload Image on  Cloud Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadImageFile(String path, XFile image) async {
    try {
      final ref = _firebaseStorage.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    }   catch (e) {
      throw 'Something loading image data: $e';
    }
  }
}