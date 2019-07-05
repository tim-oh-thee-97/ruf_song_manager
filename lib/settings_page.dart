import 'package:flutter/material.dart';

class Settings extends StatefulWidget{
  Settings({Key key, this.admin}) : super(key: key);

  //Only allow editing if admin is true!
  //On second thought, maybe allow editing anyway since it doesn't matter
  final bool admin;

  @override
  _SettingsState createState() => _SettingsState();
}

final String pageTitle = "Settings";

class _SettingsState extends State<Settings>{
  final int _defaultSongsPerSetlist = 4;
  final int _defaultWksBeforeReuse = 4;
  //TODO: Get Spotify URL
  final String _defaultSpotifyURL = "TODO";

  int _songsPerSetlist, _wksBeforeReuse;
  String _spotifyURL;

  final double _pad = 10.0;

  TextEditingController _songsPerSetlistInput = TextEditingController();
  TextEditingController _wksBeforeReuseInput = TextEditingController();
  TextEditingController _spotifyURLInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _songsPerSetlistInput.dispose();
    _wksBeforeReuseInput.dispose();
    _spotifyURLInput.dispose();
  }

  @override
  void initState(){
    super.initState();
    //TODO: Read settings from shared_preferences and populate fields
    //Set to default if not found
  }

  @override
  Widget build(BuildContext context) {

    final settingsWidgets = <Widget>[
      //TODO: Populate this list
      Text("Test"),
      SizedBox(height: _pad),
      Text("Test 2"),
      SizedBox(height: _pad),
      Text("Test 3"),
      SizedBox(height: _pad),
      //Input
      //Error message (or null)
      //...
    ];

    // TODO: finish build
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle),),
      //TODO: Check changes if user presses back button, "Do you want to save changes?"
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
          //TODO: Validate fields when outside area is tapped
        },
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              //TODO: Do I want a background image for this page?
              image: AssetImage("assets/images/ruf_photo.jpg"),
              fit: BoxFit.cover,
              matchTextDirection: true,
              //Reduce opacity of background image
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.15),
                  BlendMode.dstATop
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(_pad),
            child: Center(
              child: ListView(
                children: settingsWidgets,
              ),
            ),
          ),
        ),
      ),

      //Done button submits changes. Every other way of exiting must ask
      //"Do you want to save changes?"
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        heroTag: null,
        tooltip: "Done",
        //TODO: implement submit (validate inputs, check changes)
        onPressed: null,
      ),
    );
  }
}