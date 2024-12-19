import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/image_strings.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.status,
    required this.imageUrl,
    required this.isRead,
    required this.isComing,
    required this.senderName
  });

  final dynamic message;
  final String senderName;
  final String time, status, imageUrl;
  final bool isRead, isComing;

  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);
    // final UserModel sender =aw ContactsController .instance.getUser(senderId);

    return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
            isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // isThread ? ElevatedButton(onPressed: () {}, child: const Text("Thread")):

              /// Message Body
              RoundedContainer(
                isMessageContainer: true,
                backgroundColor: isComing
                    ? TColors.black
                    : TColors.primary.withOpacity(0.5),
                constraints: BoxConstraints(
                  maxWidth: THelperFunctions.screenWidth() * 0.8
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Sender_Name
                      Text(senderName, style: TextStyle(color: isComing ? Colors.yellow : TColors.white, fontSize: 10)),
                      if (imageUrl != '')
                        /// Image Message Body
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                              constraints: BoxConstraints(
                                maxHeight: THelperFunctions.screenHeight() / 2,
                                maxWidth: THelperFunctions.screenWidth() / 1.5
                              ),
                              child: CachedNetworkImage(imageUrl: imageUrl),
                        )),

                      /// Text Message Outline
                      message.isNotEmpty ? Text(message, style: Theme.of(context).textTheme.titleSmall)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Row(
                mainAxisAlignment:
                isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Text("$time  ",
                      style: Theme.of(context).textTheme.labelLarge),
                  if (!isComing)
                    Image.asset(isRead? TImages.doubleTick : TImages.singleTick, height: 20,  width: 20, color: isRead ? Colors.blueAccent : Colors.white60)
                ],
              ),
            ],
          ),
      );
  }
}
