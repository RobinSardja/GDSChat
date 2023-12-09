import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras[1];

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) =>
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: TakePictureScreen(
          camera: firstCamera,
        ),
      ),
    )
  );
  
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  late XFile image;
  late String contact;

  final pageController = PageController();

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
    
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    
    _controller.dispose();
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
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(child: CameraPreview(_controller));
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
                  await _initializeControllerFuture;
                  image = await _controller.takePicture();

                  late String content;
        
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
                              content = selectedIndex == 0 ? "Picture shared!" : "Picture deleted";
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(content),
                              action: SnackBarAction(
                                label: "Ok",
                                onPressed: () {},
                              ),
                              behavior: SnackBarBehavior.floating,
                            ));
                            Navigator.of(context).pop();
                          }
                        )
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
          )
        ],
        currentIndex: currentIndex,
        onTap: (selectedIndex) {
          changeIndex(selectedIndex);
          pageController.jumpToPage(selectedIndex);
        }
      ),
    );
  }
}