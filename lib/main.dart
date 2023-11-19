import 'package:flutter/material.dart';

void main() {
  runApp( const MainApp() ) ;
}

ThemeData theme = ThemeData.dark();

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
      theme: theme,
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
            CameraPage(),
            MessagePage(),
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
          selectedFontSize: 0,
          iconSize: 32,
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const Scaffold(
        body: Center(child: Text("Camera")),
      )
    );
  }
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const Scaffold(
        body: Center(child: Text("Message")),
      )
    );
  }
}