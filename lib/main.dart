import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final camera = cameras[1];

  runApp( MainApp( camera: camera ) ) ;
}

ThemeData theme = ThemeData.dark();

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  PageController pageController = PageController();

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

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
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if( snapshot.connectionState == ConnectionState.done ) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            ),
            const MessagePage(),
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