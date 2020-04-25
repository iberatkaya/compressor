import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_player/video_player.dart';

import 'utils.dart';

class VideoPage extends StatefulWidget {
  VideoPage({Key key, this.file, this.quality}) : super(key: key);
  
  final File file;
  final int quality;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  Subscription _subscription;
  VideoPlayerController _controller;
  VideoPlayerController _controller2;
  Future<void> _initializer;
  bool playing = false;
  bool playing2 = false;
  bool loaded2 = false;
  int compFileSize = 0;
  var textS = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300);

  @override
  void initState() {
    super.initState();
    var controller = VideoPlayerController.file(widget.file);
    _initializer = controller.initialize();
    setState(() {
      _controller = controller;
    });
    fetchVideo().then((value) async {
      await setController2(value.file);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }


  Future<MediaInfo> fetchVideo() async {
    VideoQuality quality;
    if(widget.quality < 33){
      quality = VideoQuality.LowQuality;
    }
    else if(widget.quality < 66){
      quality = VideoQuality.MediumQuality;
    }
    else {
      quality = VideoQuality.HighestQuality;
    }
    var compressor = FlutterVideoCompress();
    var info = await compressor.compressVideo(widget.file.absolute.path, quality: quality);
    return info;
  }

  Future<void> setController2 (File file) async {
    var controller2 = VideoPlayerController.file(file);
    await controller2.initialize();
    var size = await file.length();
    setState(() {
      _controller2 = controller2;
        loaded2 = true;
        compFileSize = size;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compressing Video'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: <Widget>[ 
                FutureBuilder(
                  future: _initializer,
                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if(snapshot.connectionState == ConnectionState.done){
                      return Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Text("Old File Size: " + formatBytes(widget.file.lengthSync(), 2), style: textS),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                          ),              
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller)
                          ),
                          FlatButton(
                            child: Icon(playing ? Icons.pause : Icons.play_arrow), 
                            color: Colors.blueAccent,
                            onPressed: () async {
                              playing ? await _controller.pause() : await _controller.play();
                              setState(() {
                                playing = !playing;
                              });
                            }
                          ),
                        ]
                      );
                    }
                    else {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.height * 0.08,
                          child: CircularProgressIndicator()
                        ),
                      );
                    }
                  },
                ),
                Divider(color: Colors.blue,),
                if(loaded2)
                  Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            margin: EdgeInsets.only(bottom: 8),
                            child: Text("New File Size: " + formatBytes(compFileSize, 2), style: textS),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                          ),          
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller2)
                          ),
                          FlatButton(
                            child: Icon(playing2 ? Icons.pause : Icons.play_arrow), 
                            color: Colors.blueAccent,
                            onPressed: () async {
                              playing2 ? await _controller2.pause() : await _controller2.play();
                              setState(() {
                                playing2 = !playing2;
                              });
                            }
                          ),
                        ],
                      )
                    ],                        
                  )
                else
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.height * 0.08,
                        child: CircularProgressIndicator()
                      ),
                    ),
              ],
            ),
          ),
        ),
      )
    );
  }
}