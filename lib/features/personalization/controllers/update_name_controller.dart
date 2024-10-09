import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/features/personalization/screens/profile/profile.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../chat/controllers/user_controller.dart';

class UpdateNameController extends GetxController{
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final about = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  /// init user data when Name screen appears
  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  /// Fetch User Record
  Future<void> initializeNames() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
    about.text = userController.user.value.about;
  }

  Future<void> updateUserName() async {
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
      if(!updateUserNameFormKey.currentState!.validate()){
        FullScreenLoader.stopLoading();
        return;
      }

      // Update User's first and last name in the firebase firestore
      Map<String, dynamic> name = {'FirstName' : firstName.text.trim(), 'LastName' : lastName.text.trim(), 'About' : about.text.trim()};
      await userRepository.updateSingleField(name);

      // Update the Rx User values
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();
      userController.user.value.about = about.text.trim();

      // Remove Loader
      FullScreenLoader.stopLoading();

      // Show Success Message
      Loaders.successSnackBar(title: "Successful Update", message: "Your name has been updated");

      // Move to previous Screen
      Navigator.pop(Get.overlayContext!);
      Get.off(() => const ProfileScreen());

    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }


}