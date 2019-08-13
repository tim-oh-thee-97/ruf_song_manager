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
        title: Text("Song List", textScaleFactor: 1.1,),
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

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        heroTag: null,
        tooltip: "New Song",
        //TODO: Implement onPressed (tutorial)
        onPressed: null,
      ),
    );
  }

  Widget _buildSongList(List<DocumentSnapshot> list,
      BuildContext context, int index) {
    DocumentSnapshot ds = list[index];
    String appendMaj = ds['major'] ? "major" : "minor";

    return ListTile(
      title: Text(ds.documentID),
      subtitle: Text(ds['key'] + " " + appendMaj),
        trailing:IconButton(
          icon: Icon(Icons.edit),
          tooltip: "Edit",
          //TODO: Implement onPressed (tutorial)
          onPressed: null,
        ),
      //TODO: Implement onPressed (tutorial)
      onTap: null,
    );
  }
}