//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//File imports
import 'authentication.dart';
import 'login_page.dart';
import 'song.dart';
import 'add_edit_song_page.dart';
import 'settings_page.dart' as mySettings;
import 'nav_service.dart';

class SongList extends StatefulWidget{
  SongList({Key key, this.admin, this.select}) : super(key: key);

  final bool admin, select;

  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList>{
  final mainReference = FirebaseFirestore.instance.collection('song-list');

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text(widget.select ? "Choose a Song" : "Song List", textScaleFactor: 1.1,),
        actions: widget.admin ? <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => navToPage(context, mySettings.Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () =>
                navToPage(context, LoginSignUpPage(auth: Auth(),
                  onSignedIn: () => turnOnAdmin(context,
                      SongList(admin: true, select: widget.select)),)),
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

        child: StreamBuilder<QuerySnapshot>(
          stream: mainReference.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[LinearProgressIndicator()],
              );

            List<DocumentSnapshot> docList = snapshot.data.docs;

            return ListView.builder(
              itemBuilder: (context, index) =>
                  _buildSongList(docList, context, index),
              itemCount: docList.length,
            );
          },
        ),
      ),

      floatingActionButton: widget.admin ? FloatingActionButton(
        child: Icon(Icons.add),
        heroTag: null,
        tooltip: "New Song",
        onPressed: () async {
          Song s = await navToPageWithResult(context, AddEditSongPage(song: null, inSongList: !widget.select,));
          if (s != null) {
            Navigator.pop(context, s);
          }
        },
      ) : null,
    );
  }

  Widget _buildSongList(List<DocumentSnapshot> list,
      BuildContext context, int index) {
    DocumentSnapshot ds = list[index];
    String appendMaj = ds.get('major') ? "major" : "minor";
    String keyText = "ERROR";
    if(ds.get('key').length > 1){
      keyText = ds.get('key').substring(0,1);
      switch(ds.get('key').substring(1,2)){
        case "#":
        keyText += "\u{266F}";
        break;
      case "b":
        keyText += "\u{266D}";
        break;
      default:
        break;
      }
    }
    else{
      keyText = ds.get('key');
    }

    return ListTile(
      title: Text(ds.id),
      subtitle: Text(keyText + " " + appendMaj),
        trailing: widget.admin ? IconButton(
          icon: Icon(Icons.edit),
          tooltip: "Edit",
          onPressed: (){
            Song s = new Song(
              ds.id,
              ds.get('key') ?? "",
              ds.get('major') ?? true,
              ds.get('begin') ?? false,
              ds.get('mid') ?? false,
              ds.get('end') ?? false
            );
            navToPage(context, AddEditSongPage(song: s));
          },
        ) : null,
      onTap: (){
        Song s = new Song(
            ds.id,
            ds.get('key') ?? "",
            ds.get('major') ?? true,
            ds.get('begin') ?? false,
            ds.get('mid') ?? false,
            ds.get('end') ?? false
        );
        if(!widget.select)
          _showSnackbar(s, context);
        else
          Navigator.pop(context, s);
      },
      onLongPress: (){
        if (widget.select) {
          Song s = new Song(
            ds.id,
            ds.get('key') ?? "",
            ds.get('major') ?? true,
            ds.get('begin') ?? false,
            ds.get('mid') ?? false,
            ds.get('end') ?? false
          );
		  _showSnackbar(s, context);
        }
      },
    );
  }
  
  void _showSnackbar(Song s, BuildContext ctxt) async {
    String snackText = "Tags: ";
	  if(s.begin){
	    snackText += "begin";
	    if(s.mid || s.end)
	     snackText += ", ";
	  }
    if(s.mid){
      snackText += "mid";
      if(s.end)
        snackText += ", ";
    }
    if(s.end)
      snackText += "end";

    snackText += "\n" + await _findLastUsedDate(s);

    _displaySnackBar(ctxt, Text(snackText));
  }

  Future<String> _findLastUsedDate(Song s) async {
    QuerySnapshot listOfSetlists = await FirebaseFirestore.instance.collection('past-setlists').get();
    String result = "Last used ";
    for(int i = listOfSetlists.docs.length-1; i >= 0; i--){
      if(listOfSetlists.docs[i].data().containsValue(s.title)){
        result += _createDateOfSetlist(listOfSetlists.docs[i].id);
        return result;
      }
    }
    return result + "never";
  }

  String _createDateOfSetlist(String unformatted){
    int month = int.tryParse(unformatted.substring(4,6));
    String day = unformatted.substring(6);
    String year = unformatted.substring(0,4);
    String fullDate = "";
    switch(month){
      case 1:
        fullDate += "January";
        break;
      case 2:
        fullDate += "February";
        break;
      case 3:
        fullDate += "March";
        break;
      case 4:
        fullDate += "April";
        break;
      case 5:
        fullDate += "May";
        break;
      case 6:
        fullDate += "June";
        break;
      case 7:
        fullDate += "July";
        break;
      case 8:
        fullDate += "August";
        break;
      case 9:
        fullDate += "September";
        break;
      case 10:
        fullDate += "October";
        break;
      case 11:
        fullDate += "November";
        break;
      case 12:
        fullDate += "December";
        break;
      default:
        fullDate += "ERROR";
        break;
    }
    fullDate += " " + day + ", " + year;
    return fullDate;
  }

  void _displaySnackBar(BuildContext context, Widget toShow){
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: toShow,
        duration: Duration(seconds: 2),));
  }
}