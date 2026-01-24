import 'package:flutter/material.dart';
import 'package:folicle/config/app_config.dart';
import 'package:folicle/routes/app_routes.dart';

void main() {
  runApp(const FolicleApp());
}

class FolicleApp extends StatelessWidget {
  const FolicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 224, 125, 242),
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
