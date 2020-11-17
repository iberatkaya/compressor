import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
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
  var textS =
      TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400);
  var textSub =
      TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w300);
  File compressedVideo;
  bool lock = false;

  @override
  void initState() {
    super.initState();
    var controller = VideoPlayerController.file(widget.file);
    _initializer = controller.initialize();
    controller.setLooping(true);
    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
    fetchVideo().then((value) async {
      compressedVideo = value.file;
      await setController2(value.file);
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    if (_controller2 != null) _controller2.dispose();
    super.dispose();
  }

  Future<MediaInfo> fetchVideo() async {
    VideoQuality quality;
    if (widget.quality == 1) {
      quality = VideoQuality.LowQuality;
    } else if (widget.quality == 2) {
      quality = VideoQuality.MediumQuality;
    } else {
      quality = VideoQuality.HighestQuality;
    }
    var info = await VideoCompress.compressVideo(widget.file.absolute.path,
        quality: quality, includeAudio: true);
    if (mounted) {
      setState(() {
        compFileSize = info.filesize;
      });
    }
    return info;
  }

  Future<void> setController2(File file) async {
    var controller2 = VideoPlayerController.file(file);
    await controller2.initialize();
    controller2.setLooping(true);
    if (mounted) {
      setState(() {
        _controller2 = controller2;
        loaded2 = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Compress Video'),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: _initializer,
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Text(
                              "Click the play button to play the video. Click the save button to save the video to the gallery.",
                              style: textSub),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Divider(
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: <Widget>[
                              Text(
                                  "Old File Size: " +
                                      formatBytes(widget.file.lengthSync(), 2),
                                  style: textS),
                              Divider(
                                color: Colors.transparent,
                                height: 0,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller)),
                        FlatButton(
                            child: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onPressed: () async {
                              playing
                                  ? await _controller.pause()
                                  : await _controller.play();
                              setState(() {
                                playing = !playing;
                              });
                            }),
                      ]);
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.height * 0.08,
                            child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
                Divider(
                  color: Colors.blue,
                ),
                if (loaded2)
                  Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: <Widget>[
                                Text(
                                    "New File Size: " +
                                        formatBytes(compFileSize, 2),
                                    style: textS),
                                Divider(color: Colors.white),
                                Text(
                                    "Reduction: " +
                                        ((widget.file.lengthSync() -
                                                    compFileSize) /
                                                widget.file.lengthSync() *
                                                100)
                                            .toStringAsFixed(0) +
                                        "%",
                                    style: textSub),
                                if (widget.file.lengthSync() - compFileSize < 0)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                    child: Text(
                                        "The quality was too high for the reduction to occur. Please decrease the quality for compression.",
                                        style: textSub),
                                  ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller2)),
                          FlatButton(
                              child: Icon(
                                  playing2 ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white),
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onPressed: () async {
                                playing2
                                    ? await _controller2.pause()
                                    : await _controller2.play();
                                setState(() {
                                  playing2 = !playing2;
                                });
                              }),
                          Container(
                            child: Divider(
                              color: Colors.blue,
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 28),
                            child: IgnorePointer(
                              ignoring: lock,
                              child: FlatButton(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child:
                                          Text("Save To Gallery", style: textS),
                                    ),
                                    Icon(
                                      Icons.save_alt,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                                onPressed: () async {
                                  setState(() {
                                    lock = true;
                                  });
                                  await GallerySaver.saveVideo(
                                      compressedVideo.absolute.path,
                                      albumName: "Compressed");
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.height * 0.08,
                          child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
