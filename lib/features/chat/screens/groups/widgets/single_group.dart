import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../controllers/group_controller.dart';

class SingleGroup extends StatelessWidget {
  const SingleGroup({super.key, required this.group});

  final GroupRoomModel group;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final groupController = GroupController.instance;
    final db = GroupController.instance.db;
    final auth = GroupController.instance.auth;
    final userController = UserController.instance;
    RxList<String> favouriteGroups = UserController.instance.favouriteGroups;

    String lastMessage = '';

    if (group.lastMessage != "group_created" && group.lastMessage != '') {
      final encryptedMessage = userController.stringToEncrypted(group.lastMessage!);
      lastMessage = userController.encryptor.decrypt(encryptedMessage, iv: userController.iv);
    }

    return RoundedContainer(
      backgroundColor: Colors.transparent,
      height: 80,
      child: Row(
        children: [
          /// Profile Picture
          Stack(
            children: [
              InkWell(
                  onTap: () => groupController.showEnlargedImage(group.groupProfilePicture!),
                  child: CircularImage(image: group.groupProfilePicture, isNetworkImage: group.groupProfilePicture != TImages.group)
              ),
              Obx(
                    () => Positioned(
                  child: UserController.instance.pinnedGroups.contains(group.id)
                      ? const Icon(Icons.star, color: Colors.yellow) : const SizedBox(),
                ),
              )
            ],
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Group name & Last Message
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(group.groupName, style: dark? Theme.of(context).textTheme.headlineSmall!.apply(fontSizeFactor: 0.78, fontWeightDelta: 2) : Theme.of(context).textTheme.headlineSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// Read Message Tick
                    Icon(
                      group.lastMessage != ''
                          ? Icons.mark_email_read_rounded
                          : Icons.near_me, size: 18, color: Colors.blue,),
                    const SizedBox(width: 5),

                    /// Last Messenger Name

                    if (lastMessage != '')
                      Text("${group.lastMessageBy} : ", style: Theme.of(context).textTheme.titleSmall),

                    /// Last Message
                    // if (group.im != "")
                    //   const SizedBox(
                    //       child: Row(
                    //         children: [
                    //           Icon(Icons.image),
                    //           SizedBox(width: TSizes.spaceBtwItems / 4),
                    //         ],
                    //       )),
                    Flexible(
                      child: SizedBox(
                          child: Text(
                            lastMessage != ''
                                ? lastMessage
                                : "${group.createdBy.firstName} created this group",
                            style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis,)),
                    )
                  ],
                ),

              ],
            ),
          ),

          /// Favourites
          Obx(
             () => IconButton(onPressed: () async {

               /// Checking Conditions
               if (!favouriteGroups.contains(group.id)) {
                  if (!group.isArchived){

                    // Add in Favourite List
                    favouriteGroups.add(group.id);

                    // Set value "True"
                    group.isFavourite = true;

                    // Update Firebase
                    await groupController.db.collection("Users").doc(auth.currentUser!.uid)
                        .collection("Groups").doc(group.id).update({"IsFavourite" : true});

                    // Notify User
                    Loaders.customToast(message: "'${group.groupName}' is added to Favourites");

                  } else {

                    // Warning Conditions
                    Loaders.customToast(message: "You need to remove '${group.groupName}' from Archives");
                  }
                }
                else {

                  // Remove from list
                  favouriteGroups.remove(group.id);

                  // Set Value "False"
                  group.isFavourite = false;

                  // Update Firebase
                  await db.collection("Users").doc(auth.currentUser!.uid)
                      .collection("Groups").doc(group.id).update({"IsFavourite" : false});

                  // Notify User
                  Loaders.customToast(message: "'${group.groupName}' is removed from Favourites");
                }

              // Update List at Firebase
              await db.collection("Users")
                  .doc(UserController.instance.auth.currentUser!.uid)
                  .update({"FavouriteGroups" : favouriteGroups.map((user) => user.toString()).toList()});

            }, icon: favouriteGroups.contains(group.id)
                ? const Icon(Icons.favorite, color: Colors.redAccent) : const Icon(Icons.favorite_border)),
          ),


          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            /// Last Message Time
            children: [
              const SizedBox(height: TSizes.defaultSpace / 1.4),

                Text(
                    group.lastMessageTime != ''
                    ? group.lastMessageTime!.substring(11,16)
                    : "N/A", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: TSizes.defaultSpace / 4),

              /// Pin Symbol && Number of Unreads
              Row(
                children: [
                  const SizedBox(width: 5),
                  RoundedContainer(
                    backgroundColor: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(group.unreadMessages.toString(), style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.white, fontWeightDelta: 2)),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}