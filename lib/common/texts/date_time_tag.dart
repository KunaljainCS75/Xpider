import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/helpers/helper_functions.dart';
import '../custom_shapes/containers/rounded_container.dart';

class DateTimeTag extends StatelessWidget {
  const DateTimeTag({
    super.key, required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final date = DateTime.parse(text);

    return Center(
        child: Text(DateFormat("d MMMM yyyy\nh:mm a").format(date),textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleMedium!.apply(color: dark ? Colors.white70 :Colors.black87, fontSizeFactor: 0.9),));
  }
}
