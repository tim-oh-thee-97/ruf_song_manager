//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//File imports
import 'authentication.dart';
import 'login_page.dart';
import 'song.dart';
import 'add_edit_song_page.dart';
import 'settings_page.dart';
import 'nav_service.dart';

class HelpSongList extends StatefulWidget{
  HelpSongList({Key key}) : super(key: key);

  @override
  _HelpSongListState createState() => _HelpSongListState();
}

class _HelpSongListState extends State<HelpSongList>{
  //TODO: Gut this and make it help version

  final mainReference = Firestore.instance.collection('song-list');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.select ? "Choose a Song" : "Song List", textScaleFactor: 1.1,),
        actions: widget.admin ? <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => navToPage(context, Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () =>
                navToPage(context, LoginSignUpPage(auth: Auth(),
                  onSignedIn: () => turnOnAdmin(context, SongList(admin: true, select: widget.select,)),)),
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

            List<DocumentSnapshot> docList = snapshot.data.documents;

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
        onPressed: () => navToPage(context, AddEditSongPage(song: null)),
      ) : null,
    );
  }

  Widget _buildSongList(List<DocumentSnapshot> list,
      BuildContext context, int index) {
    DocumentSnapshot ds = list[index];
    String appendMaj = ds['major'] ? "major" : "minor";

    return ListTile(
      title: Text(ds.documentID),
      subtitle: Text(ds['key'] + " " + appendMaj),
        trailing: widget.admin ? IconButton(
          icon: Icon(Icons.edit),
          tooltip: "Edit",
          onPressed: (){
            Song s = new Song(
              ds.documentID,
              ds['key'],
              ds['major'],
              ds['begin'],
              ds['mid'],
              ds['end']
            );
            navToPage(context, AddEditSongPage(song: s));
          },
        ) : null,
      onTap: (){
        Song s = new Song(
            ds.documentID,
            ds['key'],
            ds['major'],
            ds['begin'],
            ds['mid'],
            ds['end']
        );
        if(!widget.select){
          String snackText = "Tags: ";
          if(ds['begin']){
            snackText += "begin";
            if(ds['mid'] || ds['end'])
              snackText += ", ";
          }
          if(ds['mid']){
            snackText += "mid";
            if(ds['end'])
              snackText += ", ";
          }
          if(ds['end'])
            snackText += "end";
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(snackText),
                            duration: Duration(seconds: 2),));
        }
        else
          Navigator.pop(context, s);
      },
      onLongPress: (){
        if (widget.select) {
          String snackText = "Tags: ";
          if (ds['begin']) {
            snackText += "begin";
            if (ds['mid'] || ds['end'])
              snackText += ", ";
          }
          if (ds['mid']) {
            snackText += "mid";
            if (ds['end'])
              snackText += ", ";
          }
          if (ds['end'])
            snackText += "end";
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(snackText),
              duration: Duration(seconds: 2),));
        }
      },
    );
  }
}