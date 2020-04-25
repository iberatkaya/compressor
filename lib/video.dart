import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  VideoPage({Key key, this.file, this.quality}) : super(key: key);
  
  final File file;
  final int quality;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    print(widget.file);
    var controller = VideoPlayerController.file(widget.file);
    print(controller);
    setState(() {
      _controller = controller;
    });
  }

  Future<MediaInfo> fetchVideo() async {
    var compressor = FlutterVideoCompress();
    var info = await compressor.compressVideo(widget.file.absolute.path);
    print(info);
    return info;
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
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: fetchVideo(),
                  builder: (BuildContext context, AsyncSnapshot<MediaInfo> snapshot) {
                    if(snapshot.hasData){
                      print(snapshot.data);
                      return Column(
                        children: <Widget>[
                          Text("New File Size: " + snapshot.data.filesize.toString()),          
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        ],                        
                      );
                    }
                    else {
                      return CircularProgressIndicator();
                    }

                  },
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}