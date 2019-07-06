//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//File imports
import 'song.dart';
import 'settings_page.dart';

class SongList extends StatefulWidget{
  SongList({Key key, this.admin}) : super(key: key);

  final bool admin;

  @override
  _SongListState createState() => _SongListState();
}

final String pageTitle = "Song List";

class _SongListState extends State<SongList>{
  final mainReference = Firestore.instance.collection('song-list');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            //TODO: Change this admin to the variable
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
                  _buildSetlistList(docList, context, index),
              itemCount: docList.length,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSetlistList(List<DocumentSnapshot> list,
      BuildContext context, int index) {
    DocumentSnapshot ds = list[index];
    String appendMaj = ds['major'] ? "major" : "minor";

    return ListTile(
      title: Text(ds.documentID),
      subtitle: Text(ds['key'] + " " + appendMaj),
        trailing: widget.admin ? IconButton(
          icon: Icon(Icons.edit),
          //TODO: implement edit song (takes you to song list with "add" button)
          onPressed: null,
        ) : null,
      //TODO: implement Snackbar on tap
      onTap: null,
    );
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}

//TODO: create add dialog, edit dialog