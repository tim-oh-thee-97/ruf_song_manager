//Package imports
import "package:flutter/material.dart";

//File imports
import 'settings_page.dart';
import 'song_list.dart';
import 'view_setlists.dart';
import 'generate_setlist.dart';

class LandingPage extends StatefulWidget{
  LandingPage({Key key, this.admin}) : super(key: key);

  final bool admin;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{
  final String title = "RUF Song Manager";
  final String _adminKey = "admin_mode";
  final double _pad = 12;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.help),
          iconSize: 32,
          //TODO: Implement open help
          onPressed: null,
        ),
        title: Center(child: Text(title, textScaleFactor: 1.1,),),
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
            //Set the background image
            image: AssetImage("assets/images/ruf_photo.jpg"),
            fit: BoxFit.cover,
            matchTextDirection: true,
            //Reduce opacity of background image
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.23),
                BlendMode.dstATop
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                6+MediaQuery.of(context).size.width * 0.15,
                6,
                6+MediaQuery.of(context).size.width * 0.15,
                6
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  heightFactor: 1.2,
                  widthFactor: 1.25,
                  child: Text("Welcome", textScaleFactor: 2.75,),
                ),

                SizedBox(height: 2.05*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("View Song List"),
                  onPressed: () => _navToPage(SongList(admin: widget.admin,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("View Past Setlists"),
                  onPressed: () => _navToPage(ViewSetlists(admin: widget.admin,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  //TODO: Add Spotify logo next to text
                  child: buttonText("Open Spotify Playlist"),
                  //TODO: Implement open Spotify
                  onPressed: null,
                ),

                SizedBox(height: 4*_pad,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: widget.admin? FloatingActionButton.extended(
        icon: Icon(Icons.music_note),
        label: Text("Generate New Setlist",
          textScaleFactor: 1.7,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "New Setlist",
        //TODO: implement onPressed: nav to generate setlist
        onPressed: null,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navToPage(Widget widget) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget)
    );
  }
}

Text buttonText(String content){
  return Text(
    content,
    textScaleFactor: 1.45,
    style: TextStyle(
      fontWeight: FontWeight.w600,
    ),
  );
}