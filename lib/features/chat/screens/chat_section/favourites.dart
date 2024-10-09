import 'package:flutter/material.dart';

import '../../../../common/appbar/appbar.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text("Favourites", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
      ),
    );
  }
}
