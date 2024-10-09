import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/styles/spacingStyles.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'login_signUp/divider.dart';
import 'login_signUp/socialbuttons.dart';
import 'loginform.dart';
import 'loginheader.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: TSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              children: [
                /// Logo, Subtitle, Title
                LoginHeader(dark: dark),

                /// FORM
                const LoginForm(),

                ///Divider
                TDivider(dividerText: TTexts.orSignInWith.capitalize!),
                const SizedBox(height: TSizes.spaceBtwSections,),

                /// Footer
                const SocialButtons()
              ],
            )),
      ),
    );
  }
}







