import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';

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

  @override
  void onInit() {
    getContactsPermission();
    fetchContacts();
    super.onInit();
  }

  void getContactsPermission() async {
    if(await Permission.contacts.isGranted){
      // Fetch Contacts
      fetchContacts();
    } else {
      // Request
      await Permission.contacts.request();
      fetchContacts();
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
    contacts = await ContactsService.getContacts();
    isLoading.value = false;
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