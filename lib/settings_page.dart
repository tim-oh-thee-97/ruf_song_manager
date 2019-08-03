//Package Imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//File Imports
import 'landing_page.dart';

class Settings extends StatefulWidget{
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

final String pageTitle = "Settings";

class _SettingsState extends State<Settings>{

  int _setlistLength, _wksBeforeReuse;
  String _spotifyURL;
  String _errorText;

  final String _setlistLengthKey = 'setlist_length';
  final String _wksBeforeReuseKey = 'wks_before_reuse';
  final String _spotifyURLKey = 'spotify_url';
  final int _defaultSetlistLength = 4;
  final int _defaultWksBeforeReuse = 4;
  final String _defaultSpotifyURL = "https://open.spotify.com/playlist/6oV0zvl4hQ0Sy7EJrqWpjp";

  final double _pad = 10.0;

  TextEditingController
    _setlistLengthInput, _wksBeforeReuseInput, _spotifyURLInput;

  @override
  void dispose(){
    super.dispose();
    _setlistLengthInput.dispose();
    _wksBeforeReuseInput.dispose();
    _spotifyURLInput.dispose();
  }

  @override
  void initState(){
    super.initState();
    //Settings should be saved on app startup
    // (if user does not already have them saved)
    _readSettings().then((returned){
      if(returned == 1)
        setState((){
          _setlistLengthInput = TextEditingController(text: _setlistLength.toString());
          _wksBeforeReuseInput = TextEditingController(text: _wksBeforeReuse.toString());
          _spotifyURLInput = TextEditingController(text: _spotifyURL);

        });
      else
        setState((){
          _setlistLengthInput = TextEditingController(text: _defaultSetlistLength.toString());
          _wksBeforeReuseInput = TextEditingController(text: _defaultWksBeforeReuse.toString());
          _spotifyURLInput = TextEditingController(text: _defaultSpotifyURL);
        });
    });
    _errorText = null;
  }

  Future<int> _readSettings() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      _setlistLength = prefs.getInt(_setlistLengthKey) ?? _defaultSetlistLength;
      _wksBeforeReuse = prefs.getInt(_wksBeforeReuseKey) ?? _defaultWksBeforeReuse;
      _spotifyURL = prefs.getString(_spotifyURLKey) ?? _defaultSpotifyURL;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {

    final String _adminKey = 'are_you_admin';

    final settingsWidgets = <Widget>[
      //TODO: Improve this formatting a lot
      Text(_errorText == null ? "" : _errorText,
        textScaleFactor: 1.4,
        style: TextStyle(
          color: Colors.red,
        ),
      ),

      SizedBox(height: _pad),

      ListTile(
        contentPadding: EdgeInsets.all(_pad),
        title: Text("Songs Per Setlist"),
        subtitle: Text(_setlistLength.toString()),
        //TODO: Implement onTap
        onTap: null,
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Songs per setlist", textScaleFactor: 2,),

          Spacer(flex: 2,),

          Expanded(
            child: TextField(
              controller: _setlistLengthInput,
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
      //TODO: Logout button

      RaisedButton(
        padding: EdgeInsets.all(_pad),
        color: Colors.red,
        child: Text("Logout"),
        onPressed: () async {
          final FlutterSecureStorage storage = FlutterSecureStorage();
          await storage.write(key: _adminKey, value: "false");
          Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
        },
      ),
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