import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/features/authentication/screens/onboarding/onboarding.dart';
import 'package:xpider_chat/routes/app_routes.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/theme/theme.dart';
import 'bindings/general_bindings.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        initialBinding: GeneralBindings(),
        getPages: AppRoutes.pages,
        home: const Scaffold(backgroundColor: Colors.black87, body: Center(child: CircularProgressIndicator(color: Colors.white)))
    );
  }
}
