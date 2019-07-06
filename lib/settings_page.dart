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
  String _errorText;

  final double _pad = 10.0;

  TextEditingController
    _songsPerSetlistInput, _wksBeforeReuseInput, _spotifyURLInput;

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
    _songsPerSetlist = _defaultSongsPerSetlist;
    _wksBeforeReuse = _defaultWksBeforeReuse;
    _spotifyURL = _defaultSpotifyURL;
    _songsPerSetlistInput = TextEditingController(text: _songsPerSetlist.toString());
    _wksBeforeReuseInput = TextEditingController(text: _wksBeforeReuse.toString());
    _spotifyURLInput = TextEditingController(text: _spotifyURL);
    _errorText = null;
  }

  @override
  Widget build(BuildContext context) {

    final settingsWidgets = <Widget>[
      //TODO: Improve this formatting a lot
      Text(_errorText == null ? "" : _errorText,
        textScaleFactor: 1.4,
        style: TextStyle(
          color: Colors.red,
        ),
      ),

      SizedBox(height: _pad),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Songs per setlist", textScaleFactor: 2,),

          Spacer(flex: 2,),

          Expanded(
            child: TextField(
              controller: _songsPerSetlistInput,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(FocusNode());
                //TODO: Validate fields
              },
              keyboardType: TextInputType.number,
              maxLength: 2,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[700]),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                counterText: "",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      SizedBox(height: _pad),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Minimum weeks before reusing a song"),

          Spacer(flex: 2,),

          Expanded(
            child: TextField(
              controller: _wksBeforeReuseInput,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(FocusNode());
                //TODO: Validate fields
              },
              keyboardType: TextInputType.number,
              maxLength: 2,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[700]),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                counterText: "",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      SizedBox(height: _pad),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Spotify URL"),

          Spacer(flex: 1,),

          Expanded(
            child: TextField(
              controller: _spotifyURLInput,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(FocusNode());
                //TODO: Validate fields
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[700]),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                counterText: "",
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),

      SizedBox(height: _pad,),

      //TODO: Checkbox for middle songs same key
    ];

    // TODO: finish build
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle, textScaleFactor: 1.1,),),
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