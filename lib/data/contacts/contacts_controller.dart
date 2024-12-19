import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';

import '../../utils/popups/loaders.dart';
import '../user/user.dart';

class ContactsController extends GetxController{
  static ContactsController get instance => Get.find();

  List<Contact> contacts = [];
  RxBool isLoading = true.obs;
  GlobalKey <FormState> addContactFormKey = GlobalKey <FormState>();

  final phone     = TextEditingController();
  final firstName = TextEditingController();
  final lastName  = TextEditingController();

  final controller = UserController.instance;
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;


  Future<void> getContactPermission() async {
    isLoading.value = true;

    // Get status
    final status = await Permission.contacts.status;

    // Check
    if(status.isGranted){
      // Fetch Contacts
      contacts = await ContactsService.getContacts();

      // Set Loading Value to false
      isLoading.value = false;
    } else{
      // Request
      Permission.contacts.request();
      Loaders.warningSnackBar(title: "Contacts", message: "Go to App Settings, and allow contacts permission");
    }
  }
  void addNewContact() async {
    // Create a new contact
    Contact newContact = Contact(
      givenName: firstName.text.trim(),
      familyName: lastName.text.trim(),
      phones: [Item(label: 'mobile', value: "+91${phone.text.trim()}")],
    );

    // Add the contact to the phone's contacts list
    await ContactsService.addContact(newContact);
    print("Contact added successfully");

    fetchContacts();
  }

  void fetchContacts() async {
    if (await Permission.contacts.isGranted) {

    } else {

    }
  }


  
  Future<UserModel> getUser(String userId) async {
    final user = await db.collection("Users").doc(userId).get();
    return UserModel.fromSnapshot(user);
  }

  Future <List<Contact>> getContactBySearch (String name) async{


    List <Contact> resultContacts = [];

    for (var contact in contacts) {
      if (contact.displayName!.toLowerCase().contains(name.toLowerCase())){
        resultContacts.add(contact);
      }
    }
    return resultContacts;
  }
}
//
// Future<void> getContactPermission() async {
//   isLoading.value = true;
//
//   // Get status
//   final status = await Permission.contacts.status;
//
//   // Check
//   if(status.isGranted){
//     // Fetch Contacts
//     contacts = await ContactsService.getContacts();
//
//     // Set Loading Value to false
//     isLoading.value = false;
//   } else if (status.isDenied){
//     // Request
//     PermissionStatus newStatus = await Permission.contacts.request();
//
//     // Check new status
//     if (newStatus.isGranted) {
//       contacts = await ContactsService.getContacts();
//       isLoading.value = false;
//     }
//   } else if (status.isPermanentlyDenied){
//
//     // Go to Manual Settings
//     final opened = await openAppSettings();
//
//     if (opened) {
//       // Show instructions dialog after opening settings
//       showDialog(
//           context: Get.overlayContext!, // Pass your BuildContext here
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text("Permission Required"),
//               content: const Text(
//                   "Please go to Permissions and allow Contacts access for this app."
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text("OK"),
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                   },
//                 ),
//               ],
//             );}
//       );
//     }
//
//   }
// }