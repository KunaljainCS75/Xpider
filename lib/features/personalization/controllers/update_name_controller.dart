import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/data/repositories/group/group_repository.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/screens/groups/group_profile.dart';
import 'package:xpider_chat/features/chat/screens/groups/groups.dart';
import 'package:xpider_chat/features/chat/screens/messages/group_message_screen.dart';
import 'package:xpider_chat/features/personalization/screens/profile/profile.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../chat/controllers/user_controller.dart';

class UpdateNameController extends GetxController{
  static UpdateNameController get instance => Get.find();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final about = TextEditingController();
  final groupName = TextEditingController();
  final groupDescription = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  final groupRepository = GroupRepository.instance;
  GlobalKey<FormState> updateFieldsFormKey = GlobalKey<FormState>();

  /// init user data when Name screen appears
  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  /// Fetch User Record
  Future<void> initializeNames({GroupRoomModel? group}) async {
    try {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
    about.text = userController.user.value.about;
    groupName.text = group!.groupName;
    groupDescription.text = group.description!;
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateDetails({bool isGroup = false, GroupRoomModel? group}) async {
    try{
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your personal information. This may take a while...', TImages.onBoardingImage3);

      // Check Internet Connection
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if(!updateFieldsFormKey.currentState!.validate()){
        FullScreenLoader.stopLoading();
        return;
      }

      if (!isGroup) {
        // Update User's first and last name in the firebase firestore
        Map<String, dynamic> name = {
          'FirstName': firstName.text.trim(),
          'LastName': lastName.text.trim(),
          'About': about.text.trim()
        };
        await userRepository.updateSingleField(name);

        // Update the Rx User values
        userController.user.value.firstName = firstName.text.trim();
        userController.user.value.lastName = lastName.text.trim();
        userController.user.value.about = about.text.trim();

        // Remove Loader
        FullScreenLoader.stopLoading();

        // Show Success Message
        Loaders.successSnackBar(
            title: "Successful Update", message: "Your name has been updated");

        // Move to previous Screen
        Navigator.pop(Get.overlayContext!);
        Get.off(() => const ProfileScreen());

      } else {
        // Update User's first and last name in the firebase firestore
        Map<String, dynamic> name = {
          'GroupName': groupName.text.trim(),
          'GroupDescription': groupDescription.text.trim(),
        };
        await groupRepository.updateFields(group: group!, json: name);

        // Update the Rx User values
        group.groupName = groupName.text.trim();
        group.description = groupDescription.text.trim();

        // Remove Loader
        FullScreenLoader.stopLoading();

        // Show Success Message
        Loaders.successSnackBar(
            title: "Successful Update", message: "Group Name & Description has been updated");

        // Move to previous Screen
        Navigator.pop(Get.overlayContext!);
        Navigator.pop(Get.overlayContext!);
        Navigator.pop(Get.overlayContext!);
      }

    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }


}