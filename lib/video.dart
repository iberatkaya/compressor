import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'utils.dart';

class VideoPage extends StatefulWidget {
  VideoPage({Key key, this.file, this.quality}) : super(key: key);
  
  final File file;
  final int quality;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  VideoPlayerController _controller;
  VideoPlayerController _controller2;
  Future<void> _initializer;
  bool playing = false;
  bool playing2 = false;
  bool loaded2 = false;
  int compFileSize = 0;
  var textS = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300);
  var textSub = TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w200);

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
    var info = await compressor.compressVideo(widget.file.absolute.path, quality: quality, includeAudio: true);
    await GallerySaver.saveVideo(info.path);
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
        title: Text('Compress Video'),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: <Widget>[
                                Text("Old File Size: " + formatBytes(widget.file.lengthSync(), 2), style: textS),
                                Divider(color: Colors.transparent, height: 0,),
                              ],
                            ),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          ),       
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller)
                          ),
                          FlatButton(
                            child: Icon(playing ? Icons.pause : Icons.play_arrow), 
                            color: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: <Widget>[
                                Text("New File Size: " + formatBytes(compFileSize, 2), style: textS),
                                Divider(color: Colors.white),
                                Text("Reduction: " + ((widget.file.lengthSync() - compFileSize) / widget.file.lengthSync() * 100).toStringAsFixed(0) + "%", style: textSub),
                                if(widget.file.lengthSync() - compFileSize < 0)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                    child: Text("The quality was too high for the reduction to occur. Please decrease the quality for compression.", style: textSub),
                                  ),
                              ],
                            ),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          ),    
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller2)
                          ),
                          FlatButton(
                            child: Icon(playing2 ? Icons.pause : Icons.play_arrow), 
                            color: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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