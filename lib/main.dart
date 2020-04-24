import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('hey'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            FlatButton(
              onPressed: () async {
                print("*************'n**\n***************");
                var res = await Permission.storage.isUndetermined || await Permission.storage.isPermanentlyDenied || await Permission.storage.isDenied;
                if(!res){
                  var req = await Permission.storage.request();
                  if(req.isDenied){
                    Fluttertoast.showToast(msg: "Permission denied!");
                    return;
                  }
                }
                var files = await FilePicker.getMultiFilePath(type: FileType.image);
              },
              child: Text("Pick files"),
            ),

          ],
        ),
      ),
    );
  }
}
