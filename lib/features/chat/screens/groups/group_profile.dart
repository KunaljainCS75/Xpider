import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/models/group_user_model.dart';
import 'package:xpider_chat/features/chat/screens/groups/add_participant.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/participants_list.dart';
import 'package:xpider_chat/features/chat/screens/messages/message_screen.dart';
import 'package:xpider_chat/features/personalization/controllers/update_name_controller.dart';
import 'package:xpider_chat/features/personalization/screens/profile/widget/change_name.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../common/loaders/shimmer_loader.dart';
import '../../../../data/user/user.dart';
import '../../../../utils/constants/image_strings.dart';

class GroupProfile extends StatelessWidget {
  const GroupProfile({super.key, required this.group});

  final GroupRoomModel group;
  @override
  Widget build(BuildContext context) {

    final controller = UserController.instance;
    final groupController = GroupController.instance;
    RxBool isImageUploading = groupController.imageUploading;
    isImageUploading.value = false;
    RxList<GroupUserModel> participants = <GroupUserModel>[].obs;

    for (var user in group.participants){
      if (user.admin) participants.add(user);
    }
    for (var user in group.participants){
      if (user.editor) participants.add(user);
    }
    for (var user in group.participants){
      if (!user.admin && !user.editor) participants.add(user);
    }
    return Scaffold(
      appBar: TAppBar(
        actions: [
          IconButton(
              onPressed: () {
                final updateNameController = Get.put(UpdateNameController());
                updateNameController.initializeNames(group: group);
                Get.to(() => ChangeName(isGroup: true, group: group));
        }, icon: const Icon(Iconsax.edit))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Center(
                child: Column(
                  children: [

                    /// Group DP
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(
                          () => isImageUploading.value ?
                            const  ShimmerLoader(height: 120, width: 120, radius: 120, color: Colors.blue,)
                                :  CircularImage(
                                  height: 100, width: 100,
                                  image: group.groupProfilePicture,
                                  isNetworkImage: group.groupProfilePicture != TImages.group),
                        ),
                        /// Edit DP Button
                        Positioned(
                          child: RoundedContainer(
                            backgroundColor: Colors.blue,
                            child: InkWell(
                              onTap: () {
                                groupController.uploadGroupProfilePicture(group: group);

                              },
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.edit),
                              ),
                            ),
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Group Name
                    Text(group.groupName, style: Theme.of(context).textTheme.headlineMedium),

                    /// Group Members
                    Text("Group Participants : ${GroupController.instance.getGroupParticipantsLength(group).toString()}", style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Group Description
                    RoundedContainer(
                      showBorder: true,
                        width: THelperFunctions.screenWidth() ,
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Description", style: Theme.of(context).textTheme.titleSmall),
                              Text(group.description == '' ? "No Description Provided" : group.description!)
                            ],
                          ),
                        )),

                  ],
                ),
              ),

              /// Participants
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text("Participants "),
                      Icon(Icons.info_outline),
                    ],
                  ),
                  InkWell(
                    onTap: () => Get.to(() => AddParticipantScreen(group: group)),
                    child: const Icon(Icons.add_circle_outlined, color: Colors.green)
                  )
                ],
              ),

              /// Participants (ADMINS)
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (_, index) {
                    final person = participants[index];
                    return InkWell(
                      onTap: () async {
                        final UserModel user = await ContactsController.instance.getUser(person.id);
                        Get.off(() => MessageScreen(userModelReceiver: user));
                      },
                      onLongPress: () {
                        Get.defaultDialog(
                            title: "Remove participant",
                            middleText: "Are you sure, you want to remove ${person.fullName} from this group?",
                            onConfirm: () async {
                              await GroupController.instance.removeUser(group, group.participants, person.id);
                              Get.back();

                            },
                          onCancel: (){}
                        );
                      },
                      child: ParticipantsListTile(person: person),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

