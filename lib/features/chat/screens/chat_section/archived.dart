import 'package:flutter/material.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';

class ArchivedScreen extends StatelessWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text("Archived", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
      ),
    );
  }
}
