import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/popups/loaders.dart';

class SingleChat extends StatelessWidget {
  const SingleChat({super.key, required this.chatRoom});

  final ChatRoomModel chatRoom;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final chatController = ChatController.instance;
    final userController = UserController.instance;
    RxList<String> favouriteChats = UserController.instance.favouriteChats;

    final encryptedMessage = userController.stringToEncrypted(chatRoom.lastMessage ?? "Image_Message");
    final lastMessage = userController.encryptor.decrypt(encryptedMessage, iv: userController.iv);

    final UserModel receiver;
    if (chatRoom.sender.id != userController.user.value.id){
      receiver = chatRoom.sender;
    }
    else {
      receiver = chatRoom.receiver;
    }

    final lastMessageTime = DateTime.parse(chatRoom.lastMessageTime!);
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
                  onTap: () => ChatController.instance.showEnlargedImage(receiver.profilePicture),
                  child: CircularImage(
                      height: 50, width: 50,
                      image: receiver.profilePicture, isNetworkImage: receiver.profilePicture != TImages.user)
              ),

              /// Pin Star
              Positioned(
                  child: chatRoom.isPinned
                      ?  RoundedContainer(
                      backgroundColor: Colors.black87,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(Icons.star, color: Colors.yellow.shade600, size: 15),
                      )) : const SizedBox(),
                ),

            ],
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Chat name & Last Message
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(receiver.fullName, style: dark? Theme.of(context).textTheme.headlineSmall!.apply(fontSizeFactor: 0.65, fontWeightDelta: 2) : Theme.of(context).textTheme.headlineSmall),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Read Message Tick
                      const Icon(Icons.mark_email_read_rounded, size: 18, color: Colors.blue,),
                      const SizedBox(width: 5),

                      /// Last Messenger Name

                      Text("${chatRoom.sender.fullName} : ", style: Theme.of(context).textTheme.labelLarge),

                      /// Last Message
                      if (chatRoom.imgUrl != "")
                        const SizedBox(
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                SizedBox(width: TSizes.spaceBtwItems / 4),
                              ],
                            )),
                      Flexible(
                        child: SizedBox(
                            child: Text(lastMessage,
                              style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis,)),
                      )
                    ],
                  ),

              ],
            ),
          ),

          /// Favourites
          Obx(
          () => IconButton(onPressed: () async {

            if (!chatRoom.isArchived){
            if (!favouriteChats.contains(receiver.id)) {
              favouriteChats.add(receiver.id);

              Loaders.customToast(message: "'${receiver.fullName}' is added to Favourites");
              await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                  .collection("Chats").doc(chatRoom.id).update({"IsFavourite" : true});
            }
            else {
              favouriteChats.remove(receiver.id);
              Loaders.customToast(message: "'${receiver.fullName}' is removed from Favourites");
              await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                  .collection("Chats").doc(chatRoom.id).update({"IsFavourite" : false});
            }
            await chatController.db.collection("Users")
                .doc(chatController.auth.currentUser!.uid)
                .update({"Favourites" : favouriteChats.map((user) => user.toString()).toList()});
            } else {
              Loaders.customToast(message: "First Remove '${receiver.fullName}' from archives.");
            }
          }, icon: favouriteChats.contains(receiver.id)
                ? const Icon(Icons.favorite, color: Colors.redAccent) : const Icon(Icons.favorite_border)),
          ),


          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            /// Last Message Time
            children: [
              const SizedBox(height: TSizes.defaultSpace / 1.4),
              if (chatRoom.lastMessageTime!=null)
                Text(formattedTime, style: Theme.of(context).textTheme.labelSmall!.apply(fontSizeFactor: 0.8)),
              const SizedBox(height: TSizes.defaultSpace / 4),

              /// Number of Unreads
              Stack(
                alignment: Alignment.center,
                children: [
                  const Image(image: AssetImage(TImages.unreadBorder), height: 25, width: 25, color: Colors.yellowAccent,),
                  RoundedContainer(
                    backgroundColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      child: Text(chatRoom.unreadMessages.toString(), style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.white, fontWeightDelta: 2)),
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
