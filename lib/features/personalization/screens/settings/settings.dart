import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/features/personalization/screens/settings/account/account_settings.dart';
import '../../../../common/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/list_tiles/settings_menu_tile.dart';
import '../../../../common/list_tiles/user_profile_tile.dart';
import '../../../../common/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../profile/profile.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header -->
            PrimaryHeaderContainer(
                child: Column(children: [
                /// AppBar -->
                AppBar(
                  title: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Settings', style: dark? Theme.of(context).textTheme.headlineMedium!.apply(color: Colors.white) : Theme.of(context).textTheme.headlineMedium!.apply(color: Colors.white, fontSizeFactor: .87, fontWeightDelta: 2)),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections / 3),

                /// User Profile Card:
                UserProfileTile(onPressed: () => Get.to(() => const ProfileScreen())),
                const SizedBox(height: TSizes.spaceBtwSections)
              ],
            )),

            /// List of Setting options (BODY)
            Padding(padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                /// -- Account Settings
                const SizedBox(height: TSizes.spaceBtwItems),
                const SectionHeading(title: 'Account Settings', showActionButton: false),
                // const SizedBox(height: TSizes.spaceBtwItems),
                //
                SettingsMenuTile(icon: Icons.security, title: 'Privacy & Safety', subtitle: 'Security measures', onTap: () => Get.to(() => const AccountSettings())),
                SettingsMenuTile(icon: Icons.key_outlined, title: 'Account', subtitle: 'Manage your Xpider account', onTap: () => Get.to(() => const AccountSettings())),
                SettingsMenuTile(icon: Icons.mobile_friendly, title: 'Friend Requests', subtitle: 'Choose who can send requests', onTap: () => Get.to(() => const AccountSettings())),

                /// -- App Settings
                const SizedBox(height: TSizes.spaceBtwSections),
                const SectionHeading(title: 'App Settings', showActionButton: false),
                const SizedBox(height: TSizes.spaceBtwItems),
                SettingsMenuTile(icon: Iconsax.notification, title: 'Notifications', subtitle: 'Messages, groups, calling', onTap: (){},),
                SettingsMenuTile(icon: Iconsax.messages_24, title: 'Chats', subtitle: 'Theme, wallpapers, chat history', onTap: () {}),
                SettingsMenuTile(icon: Iconsax.user_cirlce_add, title: 'Invite', subtitle: 'Tell your friends about Xpider and invite them', onTap: (){},),
                // SettingsMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subtitle: 'Upload Data to your Cloud FireBase', onTap: (){}),
                // SettingsMenuTile(icon: Iconsax.location, title: 'Geolocation', subtitle: 'Set recommendation based on location', trailing: Switch(value: true, onChanged: (value) {})),
                // SettingsMenuTile(icon: Iconsax.security_user, title: 'Safe Mode', subtitle: 'Search result in safe for all ages', trailing: Switch(value: false, onChanged: (value) {})),
                // SettingsMenuTile(icon: Iconsax.image, title: 'HD Image Quality', subtitle: 'Set product image resolution', trailing: Switch(value: false, onChanged: (value) {})),
              ],
            ),)
          ],
        ),
      ),
    );
  }
}


