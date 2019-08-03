//Package imports
import 'package:flutter/material.dart';

//File imports
import 'song.dart';
import 'settings_page.dart';

class AddEditSongPage extends StatefulWidget{
  AddEditSongPage({Key key, this.song}) : super(key: key);

  final Song song;

  @override
  _AddEditSongPageState createState() => _AddEditSongPageState();
}

class _AddEditSongPageState extends State<AddEditSongPage>{

  final double _pad = 10.0;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song == null ? 'Add New Song' : 'Edit Song', textScaleFactor: 1.1,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => _navToPage(Settings()),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(_pad),
        child: Column(
          children: <Widget>[

          ],
        ),
      ),
    );
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}