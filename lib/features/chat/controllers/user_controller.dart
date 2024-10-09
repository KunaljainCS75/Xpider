import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../data/user/user.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/screens/login/login.dart';
import '../../authentication/screens/login/re_authenticate_user_login_form.dart';
import '../models/chat_room_model.dart';
import '../models/group_user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  final profileLoading = false.obs;
  final imageUploading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  RxList<UserModel> users = <UserModel>[].obs;
  final userRepository = Get.put(UserRepository());
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  RxList<String> favouriteChats = <String>[].obs;
  RxList<String> pinnedChats = <String>[].obs;
  RxList<String> archivedChats = <String>[].obs;

  RxList<String> favouriteGroups = <String>[].obs;
  RxList<String> pinnedGroups = <String>[].obs;
  RxList<String> archivedGroups = <String>[].obs;


  // RxList<ChatRoomModel> tempChatRoomList = ChatController.instance.chatRoomList;
  // RxList<ChatRoomModel> chatRoomList = ChatController.instance.chatRoomList;
  // final RxString selectedSortOption = 'AllChats'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
    fetchAllUserRecord();
  }

  GroupUserModel myGroupProfile() {
    return GroupUserModel(
        id: user.value.id,
        firstName: user.value.firstName,
        lastName: user.value.lastName,
        username: user.value.username,
        phoneNumber: user.value.phoneNumber,
        email: user.value.email,
        profilePicture: user.value.profilePicture
    );
  }

  // Fetching User Details
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  // Fetching all User Details
  Future<void> fetchAllUserRecord() async {
    try {
      profileLoading.value = true;
      final users_ = await userRepository.fetchAllUserDetails();
      users.assignAll(users_);

    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  // Save user Record from any Registration Provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      // Refresh user record (to avoid re-storing same record)
      await fetchUserRecord();
      if (user.value.id.isEmpty) {
        if (userCredentials != null) {
          // Convert Name to firstname and lastname
          final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
          final username = UserModel.generateUsername(userCredentials.user!.displayName ?? '');

          // Map Data
          final user = UserModel(
              id: userCredentials.user!.uid,
              firstName: nameParts[0],
              lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
              username: username,
              phoneNumber: userCredentials.user!.email ?? '',
              email: userCredentials.user!.phoneNumber ?? '',
              profilePicture: userCredentials.user!.photoURL ?? '',
          );

          // Save UserData
          await userRepository.saveUserRecord(user);
        }
      }
    } catch (e) {
      Loaders.warningSnackBar(
          title: "Data not saved",
          message: "Something went wrong while saving your information. You can re-save your data in your Profile."
      );
    }
  }

  void getAllPinnedChats() {
    fetchUserRecord();
    pinnedChats.assignAll(user.value.pinnedChats ?? []);
  }
  void getAllFavouriteChats() {
    fetchUserRecord();
    favouriteChats.assignAll(user.value.favourites ?? []);
  }
  void getAllArchivedChats() {
    fetchUserRecord();
    archivedChats.assignAll(user.value.archivedChats ?? []);
  }

  /// ChatFilters
  // void sortChats (String sortOption) {
  //   selectedSortOption.value = sortOption;
  //
  //   switch (sortOption) {
  //     case "Favourites" :
  //       // tempChatRoomList.removeWhere((chat) => !favourites.contains(chat.receiver));
  //       break;
  //     case "Pinned Chats" :
  //       // products.sort((a, b) => b.price.compareTo(a.price));
  //       break;
  //     case "Archived Chats" :
  //       // products.sort((a, b) => a.price.compareTo(b.price));
  //       break;
  //     case "Group Chats" :
  //       // products.sort((a, b) => a.date!.compareTo(b.date!));
  //       break;
  //     case "All" :
  //       // tempChatRoomList.clear();
  //       // tempChatRoomList.assignAll(chatRoomList);
  //       break;
  //     default:
  //       // tempChatRoomList.clear();
  //       // tempChatRoomList.assignAll(chatRoomList);
  //   }
  // }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText: 'Are you sure that you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently',
      confirm: ElevatedButton(
        onPressed: () async => deleteAccount(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
        child: const Padding(padding: EdgeInsets.symmetric(horizontal: TSizes.lg), child: Text('Delete')),
      ),
      cancel: ElevatedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, side: const BorderSide(color: TColors.primary)),
        child: const Padding(padding: EdgeInsets.symmetric(horizontal: TSizes.lg), child: Text('Cancel')),
      ),
    );
  }


  /// Delete User Account
  void deleteAccount() async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information...',
          TImages.productsSaleIllustration);

      /// First re-Authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;
      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();

          // Stop Loading
          FullScreenLoader.stopLoading();

          // ReDirect to LoginScreen
          Get.offAll(() => const LoginScreen());
        } else if (provider == 'password') {

          // Stop Loading
          FullScreenLoader.stopLoading();
          Get.off(() => const ReAuthenticateUserLoginForm());
        }
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.warningSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// ReAuthenticate Before Deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try{
      // Start Loading
      FullScreenLoader.openLoadingDialog('Deleting your account...', TImages.productsSaleIllustration);

      // Check Internet Connection
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if(!reAuthFormKey.currentState!.validate()){
        FullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();

      // Success Message
      Loaders.successSnackBar(title: "Deleted Successfully", message: "Account has been removed permanently.");

      // Remove Loader
      FullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Update User Profile picture
  uploadUserProfilePicture() async {
    try{

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
      imageUploading.value = true;

      // Upload Image
      final imageUrl = await userRepository.uploadImage('Users/Images/Profile/', image);

        QuerySnapshot snapshot = await db.collection("AllChats").where('Receiver.Email', isEqualTo: user.value.email).get();


        // Logging the number of documents returned
        // print("Number of chat rooms found: ${snapshot.docs.length}");

        // Iterate over each document and update the profile picture
        for (var chatRoom in snapshot.docs) {
          await chatRoom.reference.update({"Receiver.ProfilePicture": imageUrl});
        }

      // Update User Image Record
      Map<String, dynamic> json = {'ProfilePicture': imageUrl};
      await userRepository.updateSingleField(json);
      user.value.profilePicture = imageUrl;
      user.refresh();

      Loaders.successSnackBar(title: "Profile Picture Changed", message: "Your profile image has been updated...");}
    }
    catch (e) {
      Loaders.warningSnackBar(title: 'Oh Snap', message: "Something went wrong: $e");
    }
    finally {
      imageUploading.value = false;
    }
  }

  Future <List<UserModel>> getUsersBySearch (String name) async{
    List <UserModel> resultUsers = [];
    for (var user in users) {
      if (user.fullName.toLowerCase().contains(name.toLowerCase())){
        resultUsers.add(user);
      }
    }
    return resultUsers;
  }
}

