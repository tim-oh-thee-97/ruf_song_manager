//Package imports
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

//File imports
import 'settings_page.dart';
import 'song_list.dart';
import 'view_setlists.dart';
import 'generate_setlist.dart';
import 'login_page.dart';
import 'authentication.dart';
import 'nav_service.dart';

class LandingPage extends StatefulWidget{
  LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{

  final String _setlistLengthKey = 'setlist_length';
  final String _wksBeforeReuseKey = 'wks_before_reuse';
  final String _spotifyURLKey = 'spotify_url';
  final String _midsSameKeyKey = 'mid_same';
  final String _adminKey = 'are_you_admin';

  final int _defaultSetlistLength = 4;
  final int _defaultWksBeforeReuse = 4;
  final String _defaultSpotifyURL =
      "https://open.spotify.com/playlist/6oV0zvl4hQ0Sy7EJrqWpjp";
  final bool _defaultMidSameKey = false;
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
    _setDefaultsIfNull();
  }

  Future _setDefaultsIfNull() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt(_setlistLengthKey) == null)
      prefs.setInt(_setlistLengthKey, _defaultSetlistLength);
    if(prefs.getInt(_wksBeforeReuseKey) == null)
      prefs.setInt(_wksBeforeReuseKey, _defaultWksBeforeReuse);
    if(prefs.getString(_spotifyURLKey) == null)
      prefs.setString(_spotifyURLKey, _defaultSpotifyURL);
    if(prefs.getBool(_midsSameKeyKey) == null)
      prefs.setBool(_midsSameKeyKey, _defaultMidSameKey);
  }

  Future<bool> _getMode() async {
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
            onPressed: () => navToPage(context, Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () => navToPage(context, LoginSignUpPage(auth: Auth(),
              onSignedIn: () => turnOnAdmin(context, LandingPage(), pageOnTop: false),)),
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
                  onPressed: () => navToPage(context, SongList(admin: _appAdminMode, select: false,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  child: buttonText("View Past Setlists"),
                  onPressed: () => navToPage(context, ViewSetlists(admin: _appAdminMode,)),
                ),

                SizedBox(height: 2*_pad,),

                RaisedButton(
                  padding: EdgeInsets.all(_pad),
                  //TODO: Add Spotify logo next to text?
                  child: buttonText("Open Spotify Playlist"),
                  onPressed: () => _launchSpotifyURL(context),
                ),

                SizedBox(height: 4*_pad,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.music_note),
        label: Text("Generate New Setlist",
          textScaleFactor: 1.7,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "New Setlist",
        onPressed: () => navToPage(context, GenerateSetlist(admin: _appAdminMode)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future _launchSpotifyURL(BuildContext ctxt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Read settings and see if the url is null
    String url = prefs.getString(_spotifyURLKey) ?? _defaultSpotifyURL;
    if (await canLaunch(url)) {
      await launch(url);
    }
    else {
      Scaffold.of(ctxt)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Could not launch url. Please check settings."),
          duration: Duration(seconds: 5),));
      //throw 'Could not launch $url';
    }
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