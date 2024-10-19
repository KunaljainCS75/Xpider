import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/custom_shapes/containers/search_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_user_model.dart';
import 'package:xpider_chat/features/chat/screens/messages/message_screen.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/popups/loaders.dart';

class XpiderMembersScreen extends StatelessWidget {
  const XpiderMembersScreen({super.key, this.isGroupCreation = false});


  final bool isGroupCreation;

  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);
    final userController = UserController.instance;
    final group = GroupController.instance.groupMembers;
    userController.fetchAllUserRecord();

    RxBool isSearch = false.obs;
    final searchText = TextEditingController();

    RxList<UserModel> searchXpiderMembers = <UserModel>[].obs;
    searchXpiderMembers.assignAll(userController.users);
    searchXpiderMembers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

    final memberIds = GroupController.instance.memberIds;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
            TTexts.homeAppbarTitle,
            style: GoogleFonts.merienda(
                textStyle: Theme.of(context).textTheme.headlineMedium!.apply(
                    color: dark? TColors.white : TColors.black, fontWeightDelta: 2))
        ),
        // actions: [
        //   Obx((){
        //     return isSearch.value
        //         ? IconButton(onPressed: () => isSearch.value = !isSearch.value, icon: const Icon(Icons.cancel_rounded))
        //         : IconButton(onPressed: () => isSearch.value = !isSearch.value, icon: const Icon(Iconsax.search_normal));
        //   }),
        // ],
      ),
      body: Stack(
        children: [
          RoundedContainer(
          backgroundColor: Colors.transparent,
          child: Image(
            image: const AssetImage("assets/images/network/spiweb.png"),
            color: dark? Colors.white30 : TColors.grey,
            height: MediaQuery.of(context).size.height,
          ),
        ),
          Obx(
            () => Column(
              children: [

                /// SearchBar
                isSearch.value ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
                  child: SearchBarContainer(
                      text: 'Search Xpider Members',
                      textController: searchText,
                    onChanged: (value) async {
                       final searched = await userController.getUsersBySearch(searchText.text.trim());
                       searchXpiderMembers.clear();
                       searchXpiderMembers.assignAll(searched);
                       searchXpiderMembers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
                       },
                  ),
                ) : const SizedBox(),

                /// Xpider Members
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchXpiderMembers.length,
                    itemBuilder: (_, index) {
                      final user = searchXpiderMembers[index];
                      final GroupUserModel groupUser = GroupUserModel(
                          id: user.id,
                          firstName: user.firstName,
                          lastName: user.lastName,
                          username: user.username,
                          phoneNumber: user.phoneNumber,
                          email: user.email,
                          profilePicture: user.profilePicture
                      );

                      RxBool isSelected = false.obs;
                      return InkWell(
                        onTap: () {
                            if (isGroupCreation) {
                              if (user.id == userController.user.value.id) {
                                Loaders.customToast(
                                    message: "You will be added by default");
                                return;
                              }
                              // if (group.length == 3){
                              //   GroupController.instance.extraMembers.add(user);
                              //   GroupController.instance.size.value++;
                              // }
                              if (!memberIds.contains(user.id)) {
                                isSelected.value = true;
                                memberIds.add(groupUser.id);
                                group.add(groupUser);
                                GroupController.instance.size.value++;
                              }
                              else {
                                isSelected.value = false;
                                memberIds.remove(groupUser.id);
                                group.removeWhere((person) =>
                                person.id == groupUser.id);
                                GroupController.instance.size.value--;
                              }
                            }
                            else {
                              Get.to(() =>
                                  MessageScreen(userModelReceiver: user));
                            }
                        },
                        child: RoundedContainer(
                          backgroundColor: (user.id == userController.user.value.id) ? Colors.white24 : Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Obx(
                                () => Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircularImage(image: user.profilePicture, isNetworkImage: user.profilePicture != TImages.user),
                                      isSelected.value || memberIds.contains(user.id)
                                          ? const RoundedContainer(backgroundColor: Colors.black87, child: Icon(Icons.check_circle, color: Colors.yellow))
                                          : const SizedBox()
                                    ],
                                  ),
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${user.firstName} ${user.lastName}", style: Theme.of(context).textTheme.titleSmall,),
                                    if (user.email == userController.auth.currentUser!.email)
                                      Text('(You)',style: Theme.of(context).textTheme.labelMedium)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  ),

              ],
            ),
          )
      ]
      )
    );
  }
}
