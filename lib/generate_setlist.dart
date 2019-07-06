//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

//File imports
import 'song.dart';
import 'settings_page.dart';

class GenerateSetlist extends StatefulWidget{
  GenerateSetlist({Key key, this.admin}) : super(key: key);

  final bool admin;

  @override
  _GenerateSetlistState createState() => _GenerateSetlistState();
}

final String pageTitle = "Generate Setlist";

class _GenerateSetlistState extends State<GenerateSetlist>{
  final mainReference = Firestore.instance.collection('song-list');
  List<Song> songList;

  final int _defaultSetlistLength = 4;
  int _setlistLength;

  @override
  void initState(){
    super.initState();
    //TODO: Read settings for setlist length
    _setlistLength = _defaultSetlistLength;
    //TODO: Populate song list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => _navToPage(Settings(admin: widget.admin,)),
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            //TODO: Change this background image?
            image: AssetImage("assets/images/ruf_photo.jpg"),
            fit: BoxFit.cover,
            matchTextDirection: true,
            //Reduce opacity of background image
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.17),
                BlendMode.dstATop
            ),
          ),
        ),

        child: ListView.separated(
            itemBuilder: (context, index){
              _displaySetlist(_buildSetlist(songList), index);
            },
            separatorBuilder: (context, index){return Divider();},
            itemCount: _setlistLength,
        ),
      ),

      floatingActionButton: widget.admin? FloatingActionButton.extended(
        icon: Icon(Icons.done_outline),
        label: Text("Use This Setlist",
          textScaleFactor: 1.6,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "Use Setlist",
        //TODO: implement onPressed Use Setlist
        onPressed: null,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListTile _displaySetlist(List<Song> songsInSetlist, int index){
    Song s = songsInSetlist[index];

    return ListTile(
      leading: CircleAvatar(child: Text(index.toString())),
      title: Text(s.title),
      subtitle: Text(s.key + " " + (s.major ? "major" : "minor")),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        tooltip: "Edit",
        //TODO: implement edit song (takes you to song list with "add" button if admin)
        onPressed: null,
      ),
    );
  }

  List<Song> _buildSetlist(List<Song> allSongs) {
    //TODO: Finish this function
    List<Song> setlist = List<Song>();
    //Create random generator
    Random gen = Random.secure();

    //Populate first song
    while(true){
      int rand = gen.nextInt(allSongs.length);
      Song tryThis = allSongs[rand];
      if(tryThis.begin){
        setlist.add(tryThis);
        break;
      }
    }
    //Populate middle songs
    int numMid = 0;
    //TODO: Make some check to see if a setlist is possible with same mid keys and given length
    for(int i = 1; i < _setlistLength-1; i++)
      while(true){
        int rand = gen.nextInt(allSongs.length);
        Song tryThis = allSongs[rand];
        if (tryThis.mid && !setlist.contains(tryThis)){
          //TODO: Find a way to check the key and/or if the user wants the mids to be the same key
        }
      }
    //Populate last song
    while(true){
      int rand = gen.nextInt(allSongs.length);
      Song tryThis = allSongs[rand];
      if(tryThis.end && !setlist.contains(tryThis)){
        setlist.add(tryThis);
        break;
      }
    }
    return setlist;
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}