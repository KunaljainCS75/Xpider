// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import '../../../data/repositories/authentication/authentication_repository.dart';
//
// class SearchTextController extends GetxController  {
//   static SearchTextController get instance => Get.find();
//
//   final search = TextEditingController();
//   RxBool isLoading = true.obs;
//
//   late Map <String, dynamic> userMap;
//   void searchPersonByName() async {
//
//     // Start Loading
//     isLoading.value = true;
//     FirebaseFirestore _db = FirebaseFirestore.instance;
//
//     // Fetch Records
//     final userId = AuthenticationRepository.instance.authUser?.uid;
//     if (userId!.isEmpty) throw 'Unable to find user information. Try again after few minutes.';
//
//     final value = await _db.collection("Users").doc(userId).collection("Friends").
//                                           where("ChatName", isEqualTo: search.text).get();
//     userMap = value.docs[0].data();
//
//     // Stop Loading
//     isLoading.value = false;
//     print(userMap);
//   }
// }