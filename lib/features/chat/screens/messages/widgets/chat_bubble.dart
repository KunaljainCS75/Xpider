import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.status,
    required this.imageUrl,

    required this.isRead,
    required this.isComing
  });

  final dynamic message;
  final String time, status, imageUrl;
  final bool isRead, isComing;

  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);
      return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
            isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // isThread ? ElevatedButton(onPressed: () {}, child: const Text("Thread")):
              RoundedContainer(
                isMessageContainer: true,
                backgroundColor: dark
                    ? TColors.white.withOpacity(0.2)
                    : TColors.primary.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != '')
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                              constraints: BoxConstraints(
                                maxHeight: THelperFunctions.screenHeight() / 2,
                                maxWidth: THelperFunctions.screenWidth() / 1.5
                              ),
                              child: Image.file(File(imageUrl))),
                        ),
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
                  Text(time.substring(11, 16),
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  const Icon(Iconsax.tick_square4)
                ],
              ),
            ],
          ),
      );
  }
}
