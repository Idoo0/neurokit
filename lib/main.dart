import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const NeurokitApp());
}

class NeurokitApp extends StatelessWidget {
  const NeurokitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initRoute,
      getPages: AppRoutes.routes,
    );
  }
}
