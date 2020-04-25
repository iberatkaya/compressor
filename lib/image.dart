import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import './utils.dart';

class ImagePage extends StatefulWidget {
  ImagePage({Key key, this.file, this.quality}) : super(key: key);
  
  final File file;
  final int quality;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {


  Future<File> fetchImage () async {
    var result = await FlutterImageCompress.compressAndGetFile(
      widget.file.absolute.path, widget.file.absolute.parent.path + "/b.jpg", 
      format: CompressFormat.jpeg,
      quality: widget.quality
    );
    await GallerySaver.saveImage(result.absolute.path);
    return result;
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        title: Text('Compressing Image'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: fetchImage(),
                  builder: (context, AsyncSnapshot<File> snapshot) {
                    if(snapshot.hasData){
                      var bytes = snapshot.data.readAsBytesSync();
                      Image image = Image.memory(bytes);
                      return Column(
                        children: <Widget>[
                          Text("Old File Size: " + formatBytes(widget.file.lengthSync(), 2)),          
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35, 
                            width: MediaQuery.of(context).size.width,
                            child: ClipRect(
                              child: PhotoView(
                                imageProvider: Image.file(widget.file).image
                                )
                              )
                          ),  
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text("New File Size: " + formatBytes(snapshot.data.lengthSync(), 2)),          
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35, 
                            width: MediaQuery.of(context).size.width,
                            child: ClipRect(
                              child: PhotoView(
                                imageProvider: image.image
                              )
                            )
                          ),
                        ],
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
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}