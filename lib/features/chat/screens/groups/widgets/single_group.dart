import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

    final lastMessageTime = DateTime.parse(group.lastMessageTime!);
    String formattedTime = DateFormat('hh:mm a').format(lastMessageTime);

    return RoundedContainer(
      backgroundColor: Colors.transparent,
      height: 70,
      child: Row(
        children: [
          /// Profile Picture
          Stack(
            children: [
              InkWell(
                  onTap: () => groupController.showEnlargedImage(group.groupProfilePicture!),
                  child: CircularImage(
                    height: 50, width: 50,
                      image: group.groupProfilePicture,
                      isNetworkImage: group.groupProfilePicture != TImages.group,
                    backgroundColor: Colors.black87,
                  )
              ),

              Positioned(
                  child: group.isPinned
                      ? RoundedContainer(
                      backgroundColor: Colors.black87,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(Icons.star, color: Colors.yellow.shade600, size: 15),
                      )) : const SizedBox(),
                ),
            ],
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Group name & Last Message
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(group.groupName, style: dark ? Theme.of(context).textTheme.headlineSmall!.apply(fontSizeFactor: 0.65, fontWeightDelta: 2)
                                                  : Theme.of(context).textTheme.headlineSmall!.apply(fontSizeFactor: 0.65, fontWeightDelta: 2)),
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
                      Text("${group.lastMessageBy} : ", style: Theme.of(context).textTheme.labelLarge),

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
                          child: Row(
                            children: [
                              if (lastMessage == "Image_Message")
                                const Icon(Icons.image),
                              Text(
                                lastMessage != ''
                                    ? (lastMessage != "Image_Message" ? lastMessage : "Image")
                                    : "${group.createdBy.firstName} created this group",
                                style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                            ],
                          )),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            /// Last Message Time
            children: [
              const SizedBox(height: TSizes.defaultSpace / 1.4),

                Text(
                    group.lastMessageTime != ''
                    ? formattedTime
                    : "N/A", style: Theme.of(context).textTheme.labelLarge!.apply(fontSizeFactor: 0.8)),
              const SizedBox(height: TSizes.defaultSpace / 4),

              /// Pin Symbol && Number of Unreads
              const SizedBox(width: 5),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Image(image: AssetImage(TImages.unreadBorder), height: 25, width: 25, color: Colors.yellowAccent,),
                  RoundedContainer(
                    backgroundColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      child: Text(group.unreadMessages.toString(), style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.white, fontWeightDelta: 2)),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}