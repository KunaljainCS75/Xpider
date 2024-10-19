import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../../chat/models/group_chat_model.dart';
import '../../../controllers/update_name_controller.dart';


class ChangeName extends StatelessWidget {
  const ChangeName({super.key, this.isGroup = false, this.group});

  final bool isGroup;
  final GroupRoomModel? group;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    return Scaffold(
      /// Custom AppBar
      appBar: TAppBar(
        showBackArrow: false,
        title: Text(isGroup ? 'Name & Description' : 'Change Name', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            if (!isGroup)
              const Text("Use real name for verification. This name will appear on several pages."),
            if (!isGroup)
              const SizedBox(height: TSizes.spaceBtwSections),

            /// Text field and Button
            Form(
              key: controller.updateFieldsFormKey,
              child: Column(
                children: [
                  isGroup
                      ? TextFormField(
                    controller: controller.groupName,
                    validator: (value) => Validator.validateEmptyText('Group name', value),
                    expands: false,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 60,
                    decoration: const InputDecoration(labelText: TTexts.groupName, prefixIcon: Icon(Icons.group)),
                  ) : TextFormField(
                    controller: controller.firstName,
                    validator: (value) => Validator.validateEmptyText('First name', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),


                  isGroup
                      ? TextFormField(
                    controller: controller.groupDescription,
                    validator: (value) => Validator.validateEmptyText('Group Description', value),
                    expands: false,
                    minLines: 1,
                    maxLines: 30,
                    decoration: const InputDecoration(labelText: TTexts.groupDescription, prefixIcon: Icon(Icons.description)),
                    ) : TextFormField(
                    controller: controller.lastName,
                    validator: (value) => Validator.validateEmptyText('Last name', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  ),


                  if (!isGroup)
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                  if (!isGroup)
                    TextFormField(
                    controller: controller.about,
                    validator: (value) => Validator.validateEmptyText('About Description', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.about, prefixIcon: Icon(Icons.person_pin_outlined)),
                  ),
                ],
              )),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: isGroup
                  ? ElevatedButton(onPressed: () => controller.updateDetails(isGroup: true, group: group), child: const Text('Save'))
                  : ElevatedButton(onPressed: () => controller.updateDetails(), child: const Text('Save')),
            )
          ],
        ),
      )
    );
  }
}
