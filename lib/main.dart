import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

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

  final pageController = PageController();

  String buttonText = "Select contact";
  final FlutterContactPicker contactPicker = FlutterContactPicker();
  Contact? contact;

  int currentIndex = 0;
  void changeIndex(selectedIndex) {
    setState(() {
      currentIndex = selectedIndex;
    });
  }

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
                          title: const Text( "Your picture" ),
                        ),
                        body: Center(child: Image.file( File(image.path) )),
                        bottomNavigationBar: BottomNavigationBar(
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon( Icons.message ),
                              label: "Send",
                            ),
                            BottomNavigationBarItem(
                              icon: Icon( Icons.delete ),
                              label: "Delete",
                            )
                          ],
                          onTap: (selectedIndex) {
                            setState(() {
                              switch( selectedIndex ) {
                                case 0:
                                  content = "Picture sent!";
                                  break;
                                case 1:
                                  content = "Picture deleted";
                                  break;
                              }
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
          Center(
            child: ElevatedButton(
              child: Text(buttonText),
              onPressed: () async {
                Contact? selectedContact = await contactPicker.selectContact();
                setState(() {
                  contact = selectedContact;
                  buttonText = contact.toString();
                });
              },
            )
          )
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