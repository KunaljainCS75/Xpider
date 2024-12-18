import 'package:flutter/material.dart';

import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/images/circular_images.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/group_user_model.dart';

class ParticipantsListTile extends StatelessWidget {
  const ParticipantsListTile({
    super.key,
    required this.person, this.isCreator = false,
  });

  final GroupUserModel person;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final String position;
    final Color positionBackgroundColor, positionLabelColor;

    if (person.position == "Admin"){
      position = "Admin";
      positionBackgroundColor = TColors.primary.withOpacity(0.3);
      positionLabelColor = Colors.greenAccent;
    } else if (person.position == "Editor") {
      position = "Editor";
      positionBackgroundColor = Colors.yellow.withOpacity(0.3);
      positionLabelColor = Colors.yellowAccent;
    } else {
      position = "Member";
      positionBackgroundColor = Colors.blue.withOpacity(0.3);
      positionLabelColor = Colors.lightBlueAccent;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircularImage(image: person.profilePicture, isNetworkImage: true, height: 50, width: 50, backgroundColor: Colors.black87),
            const SizedBox(width: TSizes.spaceBtwItems / 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.fullName, style: Theme.of(context).textTheme.titleMedium),
                !isCreator
                    ? Text(position, style: TextStyle(color: positionLabelColor))
                    : const Text("Master Admin", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent))
              ],
            ),
          ],
        ),
        Text(person.phoneNumber)
      ],
    );
  }
}
