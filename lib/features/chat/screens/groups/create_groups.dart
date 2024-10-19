import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/edit_list_with_heading.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/group_buttons.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/list_with_heading.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/member_label.dart';
import 'package:xpider_chat/features/chat/screens/groups/xpider_members.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/cloud_helper_functions.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../models/group_user_model.dart';
import 'group_fill_details_screen.dart';

class CreateGroupsScreen extends StatelessWidget {
  const CreateGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final groupController = GroupController.instance;
    final group = groupController.groupMembers;
    RxBool isDiscarding = false.obs;
    print('${groupController.adminSize.value}-000');

    return Scaffold(
      appBar: TAppBar(
        title: Text("Create Xpider Group", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: false,
        actions: [

          /// Cancel Button
          TextButton(
              onPressed: (){
                groupController.groupMembers.clear();
                groupController.size.value = 0;
                groupController.memberIds.clear();
              },
              child: RoundedContainer(
                backgroundColor: Colors.blue.shade700,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text("Cancel", style: Theme.of(context).textTheme.titleMedium,),
                ),
              )
          )
        ],
      ),

      body: Stack(
        children: [
         Obx(
          () => Stack(
              children: [
                Positioned(
                  left: THelperFunctions.screenWidth() * 0.09,
                  top: THelperFunctions.screenHeight() * 0.125,
                  child: Image(
                    image: const AssetImage("assets/images/network/spider.png"),
                    color: Colors.blue.withOpacity(0.3),
                    height: 350,
                  ),
                ),
                Positioned(
                    left: THelperFunctions.screenWidth() * 0.38,
                    top: THelperFunctions.screenHeight() * 0.25,
                    child:  MemberLabel(
                        user: UserController.instance.myGroupProfile(),
                        defaultAdmin: true,
                        isRemoveButton: false)),


                if (groupController.size.value > 0)
                    Positioned(
                    left: THelperFunctions.screenWidth() * 0.15,
                    top: THelperFunctions.screenHeight() * 0.125,
                    child: MemberLabel(user: group[0])),

                if (groupController.size.value > 1)
                  Positioned(
                      left: THelperFunctions.screenWidth() * 0.65,
                      top: THelperFunctions.screenHeight() * 0.125,
                      child: MemberLabel(user: group[1])),

                if (groupController.size.value > 2)
                  Positioned(
                      left: THelperFunctions.screenWidth() * 0.2,
                      top: THelperFunctions.screenHeight() * 0.4,
                      child: MemberLabel(user: group[2])),

                if (groupController.size.value > 3)
                  Positioned(
                      left: THelperFunctions.screenWidth() * 0.6,
                      top: THelperFunctions.screenHeight() * 0.4,
                      child: MemberLabel(user: group[3])),


                if (groupController.size.value > 4)
                  Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: THelperFunctions.screenHeight() * 0.55,
                      left: TSizes.defaultSpace, right: TSizes.defaultSpace,
                    ),
                    child: EditListWithHeading(heading: "Members", list: group.sublist(4), isImage: false, mainAxisExtent: 100,),
                  ),
                ),
              ],
            ),
         ),

          /// ADD Button
          Column(
            children: [
              const SizedBox(height: TSizes.spaceBtwSections),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    /// Add Button
                    GroupButtons(icon: Icons.add, label: "Add a Member",
                        onTap: () {
                          isDiscarding.value = false;
                          Get.to(() => const XpiderMembersScreen(isGroupCreation: true),
                            transition: Transition.fade, duration: const Duration(milliseconds: 700));
                    }),
                    const SizedBox(width: TSizes.spaceBtwItems),

                    /// Create Button
                    Obx(
                      () => groupController.size.value > 0
                          ? GroupButtons(icon: Icons.create, label: "Create Group", iconBackgroundColor: Colors.purple,
                          onTap: () {
                            /// Add yourself as Admin by default
                            final myProfile = UserController.instance.user.value;
                            final groupMembers = groupController.groupMembers;
                            if (!groupMembers.contains((person) => person.id == myProfile.id)){
                              groupMembers.add(
                                  GroupUserModel(
                                      id: myProfile.id,
                                      firstName: myProfile.firstName,
                                      lastName: myProfile.lastName,
                                      username: myProfile.username,
                                      phoneNumber: myProfile.phoneNumber,
                                      email: myProfile.email,
                                      profilePicture: myProfile.profilePicture,
                                      admin: true
                                  ));
                            }
                            Get.to(() => const GroupFillDetailsScreen());
                          }
                      ) : const SizedBox()
                    ),
                  ],
                ),
              ),
              SizedBox(height: THelperFunctions.screenHeight() * 0.55),
            ],
          )
        ],
      )
    );
  }
}



