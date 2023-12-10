import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final chosenCamera = cameras[1];

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) =>
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: GDSChat(
          camera: chosenCamera,
        ),
      ),
    ),
  );
}

class GDSChat extends StatefulWidget {
  const GDSChat({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  GDSChatState createState() => GDSChatState();
}

class GDSChatState extends State<GDSChat> {

  final pageController = PageController();

  late CameraController controller;
  late Future<void> initializeControllerFuture;

  late XFile image;
  late String snackBarContent;

  int currentIndex = 0;
  void changeIndex(selectedIndex) {
    setState(() {
      currentIndex = selectedIndex;
    });
  }

  void sharePicture() async {
    await Share.shareXFiles( [image, ], );
  }

  @override
  void initState() {
    super.initState();
    
    controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text( "GDSChat" ))
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (selectedIndex) {
          changeIndex(selectedIndex);
        },
        children: [
          Scaffold(
            body: FutureBuilder<void>(
              future: initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(child: CameraPreview(controller));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Looking good!"),
                  action: SnackBarAction(
                    label: "Thanks!",
                    onPressed: () {},
                  ),
                  behavior: SnackBarBehavior.floating,
                ));
                try {
                  await initializeControllerFuture;
                  image = await controller.takePicture();
        
                  if (!mounted) return;
        
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          title: const Center(child: Text( "Your picture" )),
                        ),
                        body: Center(child: Image.file( File(image.path) )),
                        bottomNavigationBar: BottomNavigationBar(
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon( Icons.share ),
                              label: "Share",
                            ),
                            BottomNavigationBarItem(
                              icon: Icon( Icons.delete ),
                              label: "Delete",
                            )
                          ],
                          onTap: (selectedIndex) {
                            if( selectedIndex == 0 ) sharePicture();
                            setState(() {
                              snackBarContent = selectedIndex == 0 ? "Picture shared!" : "Picture deleted";
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(snackBarContent),
                              action: SnackBarAction(
                                label: "Ok",
                                onPressed: () {},
                              ),
                              behavior: SnackBarBehavior.floating,
                            ));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  //
                }
              },
              child: const Icon(Icons.camera_alt),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
          const Placeholder(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon( Icons.camera_alt ),
            label: "Camera",
          ),
          BottomNavigationBarItem(
            icon: Icon( Icons.settings ),
            label: "Settings",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (selectedIndex) {
          changeIndex(selectedIndex);
          pageController.jumpToPage(selectedIndex);
        },
      ),
    );
  }
}