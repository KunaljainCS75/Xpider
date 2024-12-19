import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
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
import '../../../../utils/popups/loaders.dart';

class GroupProfile extends StatelessWidget {
  const GroupProfile({super.key, required this.group});

  final GroupRoomModel group;
  @override
  Widget build(BuildContext context) {

    final groupController = GroupController.instance;
    final db = GroupController.instance.db;
    final auth = GroupController.instance.auth;
    groupController.getAllGroupRooms();
    GroupUserModel myProfile = groupController.myProfile;
    myProfile.id = auth.currentUser!.uid;
    RxBool isImageUploading = groupController.imageUploading;
    isImageUploading.value = false;
    RxList<GroupUserModel> participants = <GroupUserModel>[].obs;
    RxBool isLoading = false.obs;

    for (var user in group.participants){
      if (user.position == 'Admin') participants.add(user);
    }
    for (var user in group.participants){
      if (user.position == 'Editor') participants.add(user);
    }
    for (var user in group.participants){
      if (user.position == 'Member') participants.add(user);
    }
    participants.removeWhere((person) => person.id == group.createdBy.id);
    return Scaffold(
      appBar: TAppBar(
        actions: [
          IconButton(
              onPressed: () {
                if(myProfile.position != "Member") {
                  final updateNameController = Get.put(UpdateNameController());
                  updateNameController.initializeNames(group: group);
                  Get.to(() => ChangeName(isGroup: true, group: group));
                } else {
                  Loaders.errorSnackBar(title: "Access Denied", message: "You are not eligible to update this Group details..");
                }
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
                                if(myProfile.position != "Member") {
                                  groupController.uploadGroupProfilePicture(group: group);
                                } else {
                                  Loaders.errorSnackBar(title: "Access Denied", message: "You are not eligible to update this Group profile picture..");
                                }
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
                    onTap: () {
                      if (myProfile.position == "Admin") {
                        Get.to(() => AddParticipantScreen(group: group));
                      } else {
                        Loaders.warningSnackBar(title: "Action Denied", message: "Only Admins can add Members");
                      }
                      },
                    child: const Icon(Icons.add_circle_outlined, color: Colors.green)
                  )
                ],
              ),

              /// Master Leader Tile
              const SizedBox(height: TSizes.spaceBtwItems),
              InkWell(
                  onTap: () async {
                    final UserModel user = await ContactsController.instance.getUser(group.createdBy.id);
                    Get.off(() => MessageScreen(userModelReceiver: user));
                  },
                  child: ParticipantsListTile(person: group.createdBy, isCreator: true)
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              /// Participants
              Obx(
                () => Column(
                  children: [
                    isLoading.value ? const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
                          child: LinearProgressIndicator(),
                        ),
                      ],
                    ) : const SizedBox(),
                    ListView.separated(
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                      shrinkWrap: true,
                      itemCount: participants.length,
                      itemBuilder: (_, index) {
                        final person = participants[index];
                        return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: RoundedContainer(
                                      width: 300,
                                      showBorder: true,
                                      borderColor: Colors.white54,
                                      backgroundColor: Colors.indigo,
                                      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.defaultSpace / 6),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [

                                          /// Chat Message Option
                                          ListTile(
                                            leading: const Icon(Icons.account_circle),
                                            title: const Text("Message"),
                                            subtitle: const Text("Go to Chat Screen"),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final UserModel user = await ContactsController.instance.getUser(person.id);
                                              Get.off(() => MessageScreen(userModelReceiver: user));
                                            },
                                          ),

                                          /// Promotion of Member ---> Editor
                                          if (myProfile.position == "Admin" && myProfile.id == group.createdBy.id && person.position == "Member")
                                            Column(
                                              children: [
                                                const Divider(color: Colors.white),
                                                ListTile(
                                                leading: const Icon(Icons.arrow_upward_outlined),
                                                title:const Text("Promotion"),
                                                subtitle: const Text("Promote this user to Editor"),
                                                onTap: () async {
                                                  Navigator.pop(Get.overlayContext!);
                                                  if (!isLoading.value){
                                                  isLoading.value = true;
                                                  if (myProfile.position == "Admin"){
                                                    for (var user in group.participants){
                                                      DocumentReference groupDoc = db.collection("Users").doc(user.id)
                                                                              .collection('Groups').doc(group.id);

                                                      // Get the group document
                                                      DocumentSnapshot snapshot = await groupDoc.get();
                                                      List<dynamic> participants = snapshot.get('Participants');

                                                      Map<String, dynamic>? memberToUpdate = participants.firstWhere(
                                                            (member) => member['Id'] == person.id,
                                                        orElse: () => null,
                                                      );

                                                      if (memberToUpdate != null) {
                                                        // Remove the member from the array
                                                        await groupDoc.update({
                                                          'Participants': FieldValue
                                                              .arrayRemove(
                                                              [memberToUpdate]),
                                                        });

                                                        // Update the member's position
                                                        memberToUpdate['Position'] = "Editor";
                                                        person.position = "Editor";


                                                        // Add the updated member back into the array
                                                        await groupDoc.update({
                                                          'Participants': FieldValue
                                                              .arrayUnion(
                                                              [memberToUpdate]),
                                                        });
                                                        groupController.getAllGroupRooms();
                                                        isLoading.value = false;
                                                      }
                                                    }
                                                  }
                                                }
                                                }
                                                ),
                                              ],
                                            ),

                                          /// Promotion of Editor --> Admin
                                          /// Demotion of Editor --> Member
                                          if (myProfile.position == "Admin" && myProfile.id == group.createdBy.id && person.position == "Editor")
                                            Column(
                                              children: [
                                                const Divider(color: Colors.white),

                                                /// Promotion to Admin
                                                ListTile(
                                                    leading: const Icon(Icons.arrow_upward_outlined),
                                                    title:const Text("Promotion"),
                                                    subtitle: const Text("Promote this user to Admin"),
                                                    onTap: () async {
                                                      Navigator.pop(Get.overlayContext!);
                                                      if (!isLoading.value){
                                                        isLoading.value = true;
                                                        if (myProfile.position == "Admin"){
                                                          for (var user in group.participants){
                                                            DocumentReference groupDoc = db.collection("Users").doc(user.id)
                                                                .collection('Groups').doc(group.id);

                                                            // Get the group document
                                                            DocumentSnapshot snapshot = await groupDoc.get();
                                                            List<dynamic> participants = snapshot.get('Participants');

                                                            Map<String, dynamic>? memberToUpdate = participants.firstWhere(
                                                                  (member) => member['Id'] == person.id,
                                                              orElse: () => null,
                                                            );

                                                            if (memberToUpdate != null) {
                                                              // Remove the member from the array
                                                              await groupDoc.update({
                                                                'Participants': FieldValue
                                                                    .arrayRemove(
                                                                    [memberToUpdate]),
                                                              });

                                                              // Update the member's position
                                                              memberToUpdate['Position'] = "Admin";
                                                              person.position = "Admin";


                                                              // Add the updated member back into the array
                                                              await groupDoc.update({
                                                                'Participants': FieldValue
                                                                    .arrayUnion(
                                                                    [memberToUpdate]),
                                                              });
                                                              groupController.getAllGroupRooms();
                                                              isLoading.value = false;
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                ),
                                                const Divider(color: Colors.white70),

                                                /// Demotion to Member
                                                ListTile(
                                                    leading: const Icon(Icons.arrow_downward_outlined),
                                                    title:const Text("Demotion"),
                                                    subtitle: const Text("Demote this user to Member"),
                                                    onTap: () async {
                                                      Navigator.pop(Get.overlayContext!);
                                                      if (!isLoading.value){
                                                        isLoading.value = true;
                                                        if (myProfile.position == "Admin"){
                                                          for (var user in group.participants){
                                                            DocumentReference groupDoc = db.collection("Users").doc(user.id)
                                                                .collection('Groups').doc(group.id);

                                                            // Get the group document
                                                            DocumentSnapshot snapshot = await groupDoc.get();
                                                            List<dynamic> participants = snapshot.get('Participants');

                                                            Map<String, dynamic>? memberToUpdate = participants.firstWhere(
                                                                  (member) => member['Id'] == person.id,
                                                              orElse: () => null,
                                                            );

                                                            if (memberToUpdate != null) {
                                                              // Remove the member from the array
                                                              await groupDoc.update({
                                                                'Participants': FieldValue
                                                                    .arrayRemove(
                                                                    [memberToUpdate]),
                                                              });

                                                              // Update the member's position
                                                              memberToUpdate['Position'] = "Member";
                                                              person.position = "Member";


                                                              // Add the updated member back into the array
                                                              await groupDoc.update({
                                                                'Participants': FieldValue
                                                                    .arrayUnion(
                                                                    [memberToUpdate]),
                                                              });
                                                              groupController.getAllGroupRooms();
                                                              isLoading.value = false;
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                ),
                                              ],
                                            ),
                                          /// Demotion of Leader ---> Editor
                                          if (myProfile.position == "Admin" && myProfile.id == group.createdBy.id && person.position == "Admin")
                                            Column(
                                              children: [
                                                const Divider(color: Colors.white70),
                                                ListTile(
                                                  leading: const Icon(Icons.arrow_downward_rounded),
                                                  title: const Text("Demotion"),
                                                  subtitle: const Text("Demote this user to Editor"),
                                                  onTap: () async {
                                                    Navigator.pop(Get.overlayContext!);
                                                    if (!isLoading.value){
                                                    isLoading.value = true;
                                                    if (auth.currentUser!.uid == group.createdBy.id){
                                                      for (var user in  group.participants){
                                                        DocumentReference groupDoc = db.collection("Users").doc(user.id)
                                                            .collection('Groups').doc(group.id);

                                                        // Get the group document
                                                        DocumentSnapshot snapshot = await groupDoc.get();
                                                        List<dynamic> participants = snapshot.get('Participants');

                                                        Map<String, dynamic>? memberToUpdate = participants.firstWhere(
                                                              (member) => member['Id'] == person.id,
                                                          orElse: () => null,
                                                        );

                                                        if (memberToUpdate != null) {
                                                          // Remove the member from the array
                                                          await groupDoc.update({
                                                            'Participants': FieldValue
                                                                .arrayRemove(
                                                                [memberToUpdate]),
                                                          });

                                                          // Update the member's position
                                                          memberToUpdate['Position'] = "Editor";
                                                          person.position = "Editor";


                                                          // Add the updated member back into the array
                                                          await groupDoc.update({
                                                            'Participants': FieldValue
                                                                .arrayUnion(
                                                                [memberToUpdate]),
                                                          });
                                                          groupController.getAllGroupRooms();
                                                          isLoading.value = false;

                                                        }
                                                      }
                                                    }
                                                  }}
                                                ),
                                              ],
                                            ),
                                          if (myProfile.position == "Admin" && myProfile.id != person.id)
                                            Column(
                                              children: [
                                                const Divider(color: Colors.white),
                                                ListTile(
                                                  leading: const Icon(Icons.logout),
                                                  title: const Text("Remove"),
                                                  subtitle: const Text("Kick out this user from the group"),
                                                  onTap: () {
                                                    if (person.position != 'Admin') {
                                                      groupController.removeUser(group, participants, person.id);
                                                      Navigator.pop(context);
                                                    } else {
                                                      Loaders.warningSnackBar(title: "Action Denied", message: "You can only remove Editors and Members");
                                                    }
                                                  },
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },

                            onLongPress: () {

                          },
                          child: ParticipantsListTile(person: person)
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

