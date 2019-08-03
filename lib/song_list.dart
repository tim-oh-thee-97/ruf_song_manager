//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//File imports
import 'authentication.dart';
import 'login_page.dart';
import 'song.dart';
import 'add_edit_song_page.dart';
import 'settings_page.dart';

class SongList extends StatefulWidget{
  SongList({Key key, this.admin, this.select}) : super(key: key);

  final bool admin, select;

  @override
  _SongListState createState() => _SongListState();
}

final String pageTitle = "Song List";

class _SongListState extends State<SongList>{
  final mainReference = Firestore.instance.collection('song-list');
  final String _adminKey = 'are_you_admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
        actions: widget.admin ? <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => _navToPage(Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () =>
                _navToPage(
                    LoginSignUpPage(auth: Auth(), onSignedIn: _turnOnAdmin,)),
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
        onPressed: () => _navToPage(AddEditSongPage(song: null)),
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
            _navToPage(AddEditSongPage(song: s));
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
    );
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }

  void _turnOnAdmin() async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: _adminKey, value: "true");
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SongList(admin: true,)));
  }
}