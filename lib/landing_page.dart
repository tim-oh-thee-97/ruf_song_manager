//Package imports
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//File imports
import 'settings_page.dart';
import 'song_list.dart';
import 'view_setlists.dart';
import 'generate_setlist.dart';
import 'login_page.dart';
import 'authentication.dart';

class LandingPage extends StatefulWidget{
  LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{

  final String _setlistLengthKey = 'setlist_length';
  final String _wksBeforeReuseKey = 'wks_before_reuse';
  final String _spotifyURLKey = 'spotify_url';
  final String _adminKey = 'are_you_admin';

  int _setlistLength;
  final int _defaultSetlistLength = 4;
  final int _defaultWksBeforeReuse = 4;
  final String _defaultSpotifyURL =
      "https://open.spotify.com/playlist/6oV0zvl4hQ0Sy7EJrqWpjp";
  bool _appAdminMode = false;

  final String title = "RUF Song Manager";
  final double _pad = 12;

  @override
  void initState(){
    super.initState();
    _getMode().then((result){
      setState((){
        _appAdminMode = result;
      });
    });
    _setDefaultsIfNull().then((result){
      if(result != null)
        _setlistLength = result;
      else
        _setlistLength = _defaultSetlistLength;
    });
  }

  Future<int> _setDefaultsIfNull() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt(_setlistLengthKey) == null)
      prefs.setInt(_setlistLengthKey, _defaultSetlistLength);
    if(prefs.getInt(_wksBeforeReuseKey) == null)
      prefs.setInt(_wksBeforeReuseKey, _defaultWksBeforeReuse);
    if(prefs.getString(_spotifyURLKey) == null)
      prefs.setString(_spotifyURLKey, _defaultSpotifyURL);
    return prefs.getInt(_setlistLengthKey);
  }

  Future<bool> _getMode() async{
    final FlutterSecureStorage storage = FlutterSecureStorage();
    String _admin = await storage.read(key: _adminKey) ?? "false";
    if(_admin == "true")
      return true;
    else
      return false;
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
        actions: _appAdminMode ? <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => _navToPage(Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () => _navToPage(LoginSignUpPage(auth: Auth(), onSignedIn: _turnOnAdmin,)),
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

                //TODO: Remove this
                Text(_appAdminMode.toString()),

                SizedBox(height: 2.05*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("View Song List"),
                  onPressed: () => _navToPage(SongList(admin: _appAdminMode, select: false,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("View Past Setlists"),
                  onPressed: () => _navToPage(ViewSetlists(admin: _appAdminMode,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  //TODO: Add Spotify logo next to text
                  child: buttonText("Open Spotify Playlist"),
                  //TODO: Implement open Spotify
                  onPressed: null,
                ),

                SizedBox(height: 2*_pad,),

                //TODO: Remove this
                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("Toggle Admin (DEBUG ONLY)"),
                  onPressed: () async{
                    final FlutterSecureStorage storage = FlutterSecureStorage();
                    if(_appAdminMode)
                      await storage.write(key: _adminKey, value: "false");
                    else
                      await storage.write(key: _adminKey, value: "true");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
                  },
                ),

                SizedBox(height: 4*_pad,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _appAdminMode ? FloatingActionButton.extended(
        icon: Icon(Icons.music_note),
        label: Text("Generate New Setlist",
          textScaleFactor: 1.7,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "New Setlist",
        onPressed: () => _navToPage(GenerateSetlist(admin: _appAdminMode, setlistLength: _setlistLength,)),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
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