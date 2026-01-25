import 'package:flutter/material.dart';
import 'package:folicle/config/app_config.dart';
import 'package:folicle/routes/app_routes.dart';
//import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:folicle/models/storage.dart' as storage;

void main() async {
  // initialize hive
  await Hive.initFlutter();
  storage.weeklyHistoryBox = await Hive.openBox("boks");

  // sanity check
  storage.weeklyHistoryBox.put("foo", 42);
  int bar = storage.weeklyHistoryBox.get("foo");
  assert(bar == 42);

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
