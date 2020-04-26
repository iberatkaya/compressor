import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import './utils.dart';
import 'package:random_string/random_string.dart';
import 'package:path_provider/path_provider.dart';

class ImagePage extends StatefulWidget {
  ImagePage({Key key, this.file, this.quality}) : super(key: key);
  
  final File file;
  final int quality;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  var textS = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400);
  var textSub = TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w300);

  Future<File> fetchImage () async {
    var randomname = randomAlphaNumeric(16);
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File result = await FlutterImageCompress.compressAndGetFile(
      widget.file.absolute.path, tempPath + "/" + randomname + ".jpg", 
      format: CompressFormat.jpeg,
      quality: widget.quality
    );
    await GallerySaver.saveImage(result.absolute.path, albumName: "Compressed");
    return result;
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text('Compress Image'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Text("Double click the image to zoom and examine the details.", style: textSub),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                        ),             
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Divider(),
                        ),      
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35, 
                          width: MediaQuery.of(context).size.width,
                          child: ClipRect(
                            child: PhotoView(
                              imageProvider: Image.file(widget.file).image
                              )
                            )
                        ),  
                        Container(child: Divider(color: Colors.blue,), margin: EdgeInsets.symmetric(vertical: 8),),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: <Widget>[
                              Text("New File Size: " + formatBytes(snapshot.data.lengthSync(), 2), style: textS),
                              Divider(color: Colors.white),
                              Text("Reduction: " + ((widget.file.lengthSync() - snapshot.data.lengthSync()) / widget.file.lengthSync() * 100).toStringAsFixed(0) + "%", style: textSub),
                              if(widget.file.lengthSync() - snapshot.data.lengthSync() < 0)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                                  child: Text("The quality was too high for the reduction to occur. Please decrease the quality for compression.", style: textSub),
                                ),
                            ],
                          ),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                        ),                   
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
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.height * 0.08,
                          child: CircularProgressIndicator()
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          )
        ),
      ),
    );
  }
}