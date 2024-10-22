import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/helpers/helper_functions.dart';
import '../custom_shapes/containers/rounded_container.dart';

class DateTag extends StatelessWidget {
  const DateTag({
    super.key, required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final date = DateTime.parse(text);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: RoundedContainer(
              backgroundColor: dark ? Colors.blueGrey.shade900 :Colors.white70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("${date.day} ${DateFormat.MMMM().format(date)}, ${date.year}",
                  style: Theme.of(context).textTheme.titleMedium!.apply(color: dark ? Colors.white70 :Colors.black87),),
              ))),
    );
  }
}
