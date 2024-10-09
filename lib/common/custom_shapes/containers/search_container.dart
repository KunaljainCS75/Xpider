import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/controllers/search_controller.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/helper_functions.dart';

class SearchBarContainer extends StatelessWidget {
  const SearchBarContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.message_search,
    this.showBackground = true,
    this.showBorder = true,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace), this.onChanged, this.textController,
  });

  final String text;
  final void Function(String)? onChanged;
  final IconData? icon;
  final bool showBackground, showBorder;
  final EdgeInsetsGeometry padding;
  final TextEditingController? textController;

  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);
    final controller = TextEditingController();
    return Padding(
      padding: padding,
      child: Container(
        width: TDeviceUtils.getScreenWidth(context),
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
        decoration: BoxDecoration(
            color: showBackground? (dark? TColors.dark : TColors.light) : Colors.transparent,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: showBorder? Border.all(color : TColors.grey) : null
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: dark? TColors.light: TColors.darkerGrey),
                const SizedBox(width: TSizes.spaceBtwItems),
               Expanded(child: TextField(
                  controller: textController ?? controller,
                  cursorColor: TColors.darkGrey,
                  cursorHeight: 19,
                  cursorOpacityAnimates: true,
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: text,
                    hintStyle: const TextStyle(color: TColors.darkGrey)
                  ),
                 onChanged: onChanged,

               )
               ),
              ],
            ),
            // Obx((){
            //   return searchController.isLoading.value ? const CircularProgressIndicator() : Text(searchController.userMap["ChatName"]);
            // }
            // )
          ],
        ),
      ),
    );
  }
}