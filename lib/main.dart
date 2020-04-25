import 'package:compressor/video.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import './image.dart';
import './video.dart';

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

  double value = 90.0;

  @override
  Widget build(BuildContext context) {

    var textS = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300);

    pickAndNav(String type) async {
      var res = await Permission.mediaLibrary.isUndetermined || await Permission.mediaLibrary.isPermanentlyDenied || await Permission.mediaLibrary.isDenied;
      if(res){
        var req = await Permission.mediaLibrary.request();
        if(req.isDenied){
          Fluttertoast.showToast(msg: "Permission denied!");
          return;
        }
      }
      var file = (type == "image" ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickVideo(source: ImageSource.gallery));
      if(file != null)
        Navigator.push(context, MaterialPageRoute(builder: (context) => type == "image" ? ImagePage(file: file, quality: value.toInt(),) : VideoPage(file: file, quality: value.toInt(),) ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Compressor'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  padding: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.blueAccent),
                  child: Column(
                    children: <Widget>[
                      Text("Quality: " + value.toInt().toString() + "%", style: textS,),
                      Slider(
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        value: value,
                        min: 1.0,
                        divisions: 99,
                        max: 99.0,
                        onChanged: (val) => setState(() => (value = val))
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  color: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  onPressed: () async {
                    try {
                      pickAndNav("image");
                    } catch(e) {
                      Fluttertoast.showToast(msg: e.toString());
                      print(e);
                    }
                  },
                  child: Text("Compress Image", style: textS),
                ),
                Padding(padding: EdgeInsets.only(bottom: 12)),
                FlatButton(
                  color: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  onPressed: () async {
                    try {
                      pickAndNav("video");
                    } catch(e) {
                      Fluttertoast.showToast(msg: e.toString());
                      print(e);
                    }
                  },
                  child: Text("Compress Video", style: textS),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
