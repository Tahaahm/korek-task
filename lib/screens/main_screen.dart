// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:korek_task/config/colors.dart';
import 'package:korek_task/screens/home/home_screen.dart';
import 'package:korek_task/screens/search/search_screen.dart';
import 'package:korek_task/screens/upload/upload_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

int index = 0;
List<Widget> pages = [
  HomeScreen(),
  SearchScreen(),
];

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: index == 0
            ? AppColor.backgroudColor
            : AppColor.greyColor.withOpacity(0.2),
        title: index == 0 ? Text("Home") : Text("Search"),
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (builder) => UploadScreen(),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        child: Icon(
          Icons.file_download_outlined,
          color: AppColor.blackColor,
        ),
      ),
    );
  }
}
