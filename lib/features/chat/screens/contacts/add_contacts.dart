import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/validators/validation.dart';

class AddContacts extends StatelessWidget {
  const AddContacts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ContactsController.instance;
    return Scaffold(
      appBar: TAppBar(
        title: Text("New Contact", style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.addContactFormKey,
          child: Column(
            children: [

              /// FIRST NAME
              TextFormField(
                controller: controller.firstName,
                maxLength: 15,
                validator: (value) => Validator.validateEmptyText('First name', value),
                expands: false,
                decoration: const InputDecoration(
                    labelText: TTexts.firstName,
                    prefixIcon: Icon(Iconsax.user)),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// LAST NAME
              TextFormField(
                controller: controller.lastName,
                validator: (value) => Validator.validateEmptyText('Last name', value),
                maxLength: 20,
                expands: false,
                decoration: const InputDecoration(
                    labelText: TTexts.lastName,
                    prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// PHONE
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      expands: false,
                      decoration: const InputDecoration(
                          labelText: "+91",
                          prefixIcon: Icon(Iconsax.global),
                    ),
                  ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwInputFields),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: controller.phone,
                      validator: (value) => Validator.validatePhoneNumber(value),
                      expands: false,
                      decoration: const InputDecoration(
                          labelText: TTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addNewContact();
                    controller.firstName.clear();
                    controller.lastName.clear();
                    controller.phone.clear();
                    Get.back();
                    },
                  child: const Text("Add Contact"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
