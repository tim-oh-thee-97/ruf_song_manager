//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

//File imports
import 'song.dart';

class HelpGenerateSetlist extends StatefulWidget{
  HelpGenerateSetlist({Key key}) : super(key: key);

  @override
  _HelpGenerateSetlistState createState() => _HelpGenerateSetlistState();
}

final String pageTitle = "Generate Setlist";
enum SongType { begin, mid, end }

class _HelpGenerateSetlistState extends State<HelpGenerateSetlist>{
  //TODO: Gut this and make it help version

  List<Song> songList = List<Song>();
  List<Song> setlist = List<Song>();
  List<Song> invalidSongs = List<Song>();
  bool _songListPopulated = false;
  int _setlistLength;

  @override
  void initState(){
    super.initState();
    //Populate the song list
    setState(() {
      setlist = _buildSetlistTutorial(songList);
      _songListPopulated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
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
              return _displaySetlist(setlist, context, index);
            },
            itemCount: _setlistLength,
        ) : SizedBox(
          child: CircularProgressIndicator(),
          height: 150,
          width: 150,
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.done_outline),
        label: Text("Use This Setlist",
          textScaleFactor: 1.6,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "Use Setlist",
        //TODO: Implement onPressed (tutorial)
        onPressed: null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListTile _displaySetlist(List<Song> songsInSetlist,
      BuildContext context, int index){
    Song s = songsInSetlist[index];

    return ListTile(
      leading: CircleAvatar(child: Text((index+1).toString())),
      title: Text(s.title),
      subtitle: Text(s.key + " " + (s.major ? "major" : "minor")),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        tooltip: "Edit",
        //TODO: Implement onPressed (tutorial)
        onPressed: null,
      ),
      onLongPress: (){
        if(index == 0)
          _rerollOneSongTutorial(index, SongType.begin);
        else if(index == setlist.length-1)
          _rerollOneSongTutorial(index, SongType.end);
        else
          _rerollOneSongTutorial(index, SongType.mid);
      },
    );
  }

  List<Song> _buildSetlistTutorial(List<Song> allSongs) {
    List<Song> setlist = List<Song>();
    return setlist;
  }

  void _rerollOneSongTutorial(int index, SongType type){

  }
}