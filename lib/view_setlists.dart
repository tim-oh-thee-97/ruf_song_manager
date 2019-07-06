//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';

//File imports
import 'song.dart';
import 'song_list.dart';
import 'settings_page.dart';

class ViewSetlists extends StatefulWidget{
  ViewSetlists({Key key, this.admin}) : super(key: key);

  final bool admin;

  @override
  _ViewSetlistsState createState() => _ViewSetlistsState();
}

final String pageTitle = "View Setlists";

class _ViewSetlistsState extends State<ViewSetlists>{
  final mainReference = Firestore.instance.collection('past-setlists');

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
            image: AssetImage("assets/images/quad.jpg"),
            fit: BoxFit.cover,
            matchTextDirection: true,
            //Reduce opacity of background image
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.11),
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
    var dateOfSetlist = _createDateOfSetlist(ds.documentID);

    return ExpansionTile(
      key: PageStorageKey<int>(1),
      title: Text(dateOfSetlist,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _populateOneSetlist(ds),
          ),
        )
      ],
    );
  }

  Widget _createRichText(String bold, String text) {
    return RichText(
      text: TextSpan(
          style: TextStyle(         //Rich Text allows the first part to
              color: Colors.black               //be bold
          ),
          children: <TextSpan>[
            TextSpan(text: bold,
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: text,)
          ]
      ),
    );
  }

  String _createDateOfSetlist(String unformatted){
    int month = int.tryParse(unformatted.substring(0,2));
    String day = unformatted.substring(2,4);
    String year = unformatted.substring(4);
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

  List<Widget> _populateOneSetlist(DocumentSnapshot ds){
    List<Widget> songs = List<Widget>();
    for(int i = 1; i <= ds.data.length; i++){
      String lookup = 'song' + i.toString();
      songs.add(
          ListTile(
            title: _createRichText("Song " + i.toString() + ": ", ds[lookup]),
            trailing: widget.admin ? IconButton(
              icon: Icon(Icons.edit),
              tooltip: "Edit",
              //TODO: implement edit song (takes you to song list with "add" button)
              onPressed: null,
            ) : null,
          ));
    }
    songs.add(SizedBox(height: 14));
    return songs;
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}