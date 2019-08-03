//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

//File imports
import 'song.dart';
import 'song_list.dart';
import 'settings_page.dart';

class GenerateSetlist extends StatefulWidget{
  GenerateSetlist({Key key, this.admin, this.setlistLength}) : super(key: key);

  final bool admin;
  final int setlistLength;

  @override
  _GenerateSetlistState createState() => _GenerateSetlistState();
}

final String pageTitle = "Generate Setlist";

class _GenerateSetlistState extends State<GenerateSetlist>{
  final mainReference = Firestore.instance.collection('song-list');
  List<Song> songList = List<Song>();
  bool _songListPopulated = false;

  final int _defaultSetlistLength = 4;
  int _setlistLength;

  @override
  void initState(){
    super.initState();
    //TODO: Read settings for setlist length
    _setlistLength = _defaultSetlistLength;
    _getSongList().then((done){
      setState((){
        _songListPopulated = true;
      });
    });
  }

  Future<bool> _getSongList() async{
    await mainReference.getDocuments().then((contentsOfSongList){
      for(int i = 0; i < contentsOfSongList.documents.length; i++){
        DocumentSnapshot song = contentsOfSongList.documents[i];
        songList.add(new Song(
            song.documentID,
            song['key'],
            song['major'],
            song['begin'],
            song['mid'],
            song['end']
        ));
      }
    });
    return true;
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
            onPressed: () => _navToPage(Settings()),
          ),
        ],
      ),

      body: Container(
        alignment: Alignment(0,0),
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

        child: _songListPopulated ? ListView.builder(
            itemBuilder: (context, index){
              return _displaySetlist(_buildSetlist(songList), context, index);
            },
            itemCount: _setlistLength,
        ) : SizedBox(
          child: CircularProgressIndicator(),
          height: 150,
          width: 150,
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

  ListTile _displaySetlist(List<Song> songsInSetlist,
      BuildContext context, int index){
    //TODO: This isn't displaying for some reason
    Song s = songsInSetlist[index];

    return ListTile(
      leading: CircleAvatar(child: Text((index+1).toString())),
      title: Text(s.title),
      subtitle: Text(s.key + " " + (s.major ? "major" : "minor")),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        tooltip: "Edit",
        onPressed: () async {
          Song s = await _navToPageWithResult(SongList(admin: widget.admin, select: true));
          if(s != null){
            print(s.toString());
            setState((){
              songsInSetlist[index] = s;
            });
          }
        },
      ),
    );
  }

  List<Song> _buildSetlist(List<Song> allSongs) {
    //TODO: Finish this function
    //TODO: Prevent the setlist from populating multiple times e.g. when you open settings
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
          setlist.add(tryThis);
          numMid++;
          break;
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
    for(int i = 0; i < setlist.length; i++){
      print(setlist[i].toString());
    }
    return setlist;
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget, maintainState: true)
    );
  }

  Future<Song> _navToPageWithResult(Widget widget) async {
    final Song toReturn = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget, maintainState: true)
    );
    return toReturn;
  }
}