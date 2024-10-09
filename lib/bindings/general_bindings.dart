import 'package:get/get.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(UserController());
    Get.put(ContactsController());
    Get.put(NetworkManager());
    Get.put(ChatController());
    Get.put(GroupController());
  }
}