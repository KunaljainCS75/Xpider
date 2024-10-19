import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../common/images/circular_images.dart';
import '../../../../data/user/user.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/group_user_model.dart';

class AddParticipantScreen extends StatelessWidget {
  const AddParticipantScreen({super.key, required this.group});

  final GroupRoomModel group;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final userController = UserController.instance;

    userController.fetchAllUserRecord();

    // RxBool isSearch = false.obs;
    // final searchText = TextEditingController();

    RxList<UserModel> searchXpiderMembers = <UserModel>[].obs;
    searchXpiderMembers.assignAll(userController.users);
    searchXpiderMembers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

    List<GroupUserModel> participants = <GroupUserModel>[];

    return Scaffold(
      appBar: TAppBar(
        title: Text("Add Members", style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          InkWell(
            onTap: () {
              final groupController = GroupController.instance;
              groupController.addParticipants(participants: participants, group: group);

              Get.back();
            },
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: TSizes.iconLg),
          )
        ],
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
                  // isSearch.value ? Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
                  //   child: SearchBarContainer(
                  //     text: 'Search Xpider Members',
                  //     textController: searchText,
                  //     onChanged: (value) async {
                  //       final searched = await userController.getUsersBySearch(searchText.text.trim());
                  //       searchXpiderMembers.clear();
                  //       searchXpiderMembers.assignAll(searched);
                  //       searchXpiderMembers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
                  //     },
                  //   ),
                  // ) : const SizedBox(),

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
                            isSelected.value = !isSelected.value;
                            if (isSelected.value){
                              participants.add(groupUser);
                            } else {
                              participants.removeWhere((person) => person.id == groupUser.id);
                            }
                            print(participants.length);
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
                                       isSelected.value
                                            ? const RoundedContainer(backgroundColor: Colors.white70, child: Icon(Icons.check_circle, color: Colors.blueAccent,weight: 100,))
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
