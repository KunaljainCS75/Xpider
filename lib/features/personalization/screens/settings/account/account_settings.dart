import 'package:flutter/material.dart';
import 'package:xpider_chat/utils/helpers/cloud_helper_functions.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../../common/appbar/appbar.dart';
import '../../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../chat/controllers/user_controller.dart';
import '../../profile/widget/profile_menu.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Account'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [

              /// Information
              // ProfileMenu(title: 'User-ID', value: controller.user.value.id, onPressed: (){}, icon: Iconsax.copy,),
              ProfileMenu(prefixIcon: Icons.email, title: 'Email', value: controller.user.value.email, onPressed: (){}, showIcon: false),
              ProfileMenu(prefixIcon: Icons.phone, title: 'Mobile', value: controller.user.value.formattedPhoneNo, onPressed: (){}, showIcon: false,),
              ProfileMenu(prefixIcon: Icons.delete_forever, title: 'Remove', value: "Delete your account", onPressed: () => controller.deleteAccountWarningPopup(), showIcon: false,),
              Row(
                children: [
                  const Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 25),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  TextButton(
                    onPressed: () => AuthenticationRepository().logout(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 20)),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Text("Sign-in or create a new account", style: Theme.of(context).textTheme.bodySmall!.apply(color : THelperFunctions.isDarkMode(context) ? Colors.white70 : Colors.black54, fontSizeFactor: 1), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ),
    );
  }
}
