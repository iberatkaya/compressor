import 'package:compressor/const.dart';
import 'package:compressor/video.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import './image.dart';
import './video.dart';
import 'dart:io' show Platform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compressor',
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

  double value = 60.0;
  double value2 = 2.0;
  int ctr = 0;
  List<InterstitialAd> intAd = [];
  int adFreq = 2;
  var textS = TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300);
  var textSub = TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w200);
  var textQuality = TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w300);


  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: Platform.isIOS ? iosAppId : androidAppId);
    intAd.add(InterstitialAd(adUnitId: release ? (Platform.isIOS ? iosIntersitial : androidIntersitial) : InterstitialAd.testAdUnitId));
    intAd[0].load();
  }

  checkPermDenied(Permission p) async {
    bool perm = await p.isUndetermined || await p.isPermanentlyDenied || await p.isDenied;
    return perm;
  }

  videoQuality(int val){
    if(val == 1)
      return "Low";
    else if(val == 2)
      return "Medium";
    else
      return "High";
  }
  pickAndNav(String type) async {
    var res = await checkPermDenied(Platform.isIOS ? Permission.mediaLibrary : Permission.storage); 
    if(res){
      var req = Platform.isIOS ? await Permission.mediaLibrary.request() : await Permission.storage.request();
      if(req.isDenied){
        Fluttertoast.showToast(msg: "Permission denied!");
        return;
      }
    }
    var file = (type == "image" ? await ImagePicker.pickImage(source: ImageSource.gallery) : await ImagePicker.pickVideo(source: ImageSource.gallery));
    if(file != null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => type == "image" ? ImagePage(file: file, quality: value.toInt(),) : VideoPage(file: file, quality: value2.toInt(),) ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compressor'),
        elevation: 1,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Color.fromRGBO(233, 228, 255, 1)),
                    child: Container(
                      padding: EdgeInsets.only(top: 16),
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Image.asset("icon.png")
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text("Other Apps"),
              leading: Icon(Icons.apps),
              onTap: () async {
                String url = (Platform.isIOS ? 'https://apps.apple.com/us/developer/selim-ustel/id1498230191' : 'https://play.google.com/store/apps/developer?id=IBK+Apps');
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
            ),
            ListTile(
              title: Text("Help"),
              leading: Icon(Icons.help_outline),
              onTap: (){
                showDialog(
                  context: context, 
                  child: AlertDialog(
                    title: Text("Help"),
                    content: Text("Select the quality and start compressing! Select either an image or video to compress it."),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        }, 
                        child: Text("OK")
                      )
                    ],
                  )
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        onPressed: () async {
                          try {
                            await pickAndNav("image");
                            if(ctr % adFreq == 0){
                              intAd.add(InterstitialAd(adUnitId: release ? (Platform.isIOS ? iosIntersitial : androidIntersitial) : InterstitialAd.testAdUnitId));
                              intAd[ctr ~/ adFreq + 1].load();
                              await intAd[ctr ~/ adFreq].show();
                            }
                            ctr++;
                          } catch(e) {
//                            Fluttertoast.showToast(msg: e.toString());
                            print(e);
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Image", style: textS),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                                Icon(Icons.image, color: Colors.white, size: 32,)
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Colors.white,),
                            ),
                            Text("Quality: " + value.toInt().toString() + "%", style: textQuality,),
                            Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.white38,
                              value: value,
                              min: 1.0,
                              divisions: 98,
                              max: 99.0,
                              onChanged: (val) => setState(() => (value = val))
                            ),
                            Divider(color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                              child: Text("Slide to select the quality of compresion. The smaller the quality is the smaller the image size will be. Select an image and a quality percantage and wait for the compression.", style: textSub,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.blue,),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        onPressed: () async {
                          try {
                            await pickAndNav("video");
                            if(ctr % adFreq == 0)
                              intAd.add(InterstitialAd(adUnitId: release ? (Platform.isIOS ? iosIntersitial : androidIntersitial) : InterstitialAd.testAdUnitId));
                              intAd[ctr ~/ adFreq + 1].load();
                              await intAd[ctr ~/ adFreq].show();
                            ctr++;
                          } catch(e) {
//                            Fluttertoast.showToast(msg: e.toString());
                            print(e);
                          }
                        },
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Video", style: textS),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                                Icon(Icons.play_circle_filled, color: Colors.white, size: 32,)
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Colors.white,),
                            ),
                            Text(videoQuality(value2.toInt()) + " Quality", style: textQuality,),
                            Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.white38,
                              value: value2,
                              min: 1.0,
                              divisions: 2,
                              max: 3.0,
                              onChanged: (val) => setState(() => (value2 = val))
                            ),
                            Divider(color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                              child: Text("Slide to select the quality of compresion. The smaller the quality is the smaller the image or video size will be. Select a video and a quality percantage and wait for the compression.", style: textSub,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
