import 'package:flutter/material.dart';

void main() {
  runApp( const MainApp() ) ;
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  PageController pageController = PageController();

  int currentIndex = 0;
  void changeIndex(selectedIndex) {
    setState(() {
      currentIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center( child: Text("GDSnapChat") ),
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (selectedIndex) {
            changeIndex(selectedIndex);
          },
          children: const [
            Center( child: Text( "Camera" ), ),
            Center( child: Text( "Message" ), ),
          ]
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon( Icons.camera_alt ),
              label: "Camera",
            ),
            BottomNavigationBarItem(
              icon: Icon( Icons.textsms ),
              label: "Message",
            ),
          ],
          currentIndex: currentIndex,
          onTap: (selectedIndex) {
            changeIndex(selectedIndex);
            pageController.jumpToPage(selectedIndex);
          },
        ),
      ),
    );
  }
}