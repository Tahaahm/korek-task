import 'package:flutter/material.dart';
import 'package:korek_task/config/colors.dart';
import 'package:korek_task/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primiryColor),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
