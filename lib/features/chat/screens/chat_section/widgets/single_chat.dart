import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return RoundedContainer(
      backgroundColor: Colors.transparent,
      height: 80,
      child: Row(
        children: [
          /// Profile Picture
          Stack(
            children: [
              InkWell(
                  onTap: () => ChatController.instance.showEnlargedImage(receiver.profilePicture),
                  child: CircularImage(image: receiver.profilePicture, isNetworkImage: receiver.profilePicture != TImages.user)
              ),
              Obx(
                () => Positioned(
                  child: UserController.instance.pinnedChats.contains(receiver.id)
                      ? const Icon(Icons.star, color: Colors.yellow) : const SizedBox(),
                ),
              )
            ],
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          /// Chat name & Last Message
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(receiver.fullName, style: dark? Theme.of(context).textTheme.headlineSmall!.apply(fontSizeFactor: 0.78, fontWeightDelta: 2) : Theme.of(context).textTheme.headlineSmall),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Read Message Tick
                      const Icon(Icons.mark_email_read_rounded, size: 18, color: Colors.blue,),
                      const SizedBox(width: 5),

                      /// Last Messenger Name

                      Text("${chatRoom.sender.fullName} : ", style: Theme.of(context).textTheme.titleSmall),

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

            if (!favouriteChats.contains(receiver.id)) {
              favouriteChats.add(receiver.id);
              Loaders.customToast(message: "'${receiver.fullName}' is added to Favourites");
            }
            else {
              favouriteChats.remove(receiver.id);
              Loaders.customToast(message: "'${receiver.fullName}' is removed from Favourites");
            }
            await chatController.db.collection("Users")
                .doc(chatController.auth.currentUser!.uid)
                .update({"Favourites" : favouriteChats.map((user) => user.toString()).toList()});

            }, icon: favouriteChats.contains(receiver.id)
                ? const Icon(Icons.favorite, color: Colors.redAccent) : const Icon(Icons.favorite_border)),
          ),


          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            /// Last Message Time
            children: [
              const SizedBox(height: TSizes.defaultSpace / 1.4),
              if (chatRoom.lastMessageTime!=null)
                Text(chatRoom.lastMessageTime!.substring(11,16), style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: TSizes.defaultSpace / 4),

              /// Pin Symbol && Number of Unreads
              Row(
                children: [
                  if(chatRoom.isPinned)
                    const Icon(Icons.push_pin,size: 20, color: TColors.darkGrey),
                  const SizedBox(width: 5),
                  RoundedContainer(
                    backgroundColor: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(chatRoom.unreadMessages.toString(), style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.white, fontWeightDelta: 2)),
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
