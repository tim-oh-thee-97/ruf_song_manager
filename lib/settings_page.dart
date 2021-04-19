//Package Imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';

//File Imports
import 'nav_service.dart';

class Settings extends StatefulWidget{
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

final String pageTitle = "Settings";

class _SettingsState extends State<Settings>{

  //Values
  int _setlistLength, _wksBeforeReuse;
  String _spotifyURL;
  bool _midsSameKey;
  //Prefs keys
  final String _setlistLengthKey = 'setlist_length';
  final String _wksBeforeReuseKey = 'wks_before_reuse';
  final String _spotifyURLKey = 'spotify_url';
  final String _midsSameKeyKey = 'mid_same';
  //Defaults
  final int _defaultSetlistLength = 4;
  final int _defaultWksBeforeReuse = 4;
  final String _defaultSpotifyURL = "https://open.spotify.com/playlist/6oV0zvl4hQ0Sy7EJrqWpjp";
  final bool _defaultMidsSameKey = false;

  final double _pad = 10.0;

  TextEditingController _spotifyURLInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
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
          _spotifyURLInput.text = _spotifyURL;
        });
      else
        setState((){
          _spotifyURLInput.text = _defaultSpotifyURL;
        });
    });
  }

  Future<int> _readSettings() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      _setlistLength = prefs.getInt(_setlistLengthKey) ?? _defaultSetlistLength;
      _wksBeforeReuse = prefs.getInt(_wksBeforeReuseKey) ?? _defaultWksBeforeReuse;
      _spotifyURL = prefs.getString(_spotifyURLKey) ?? _defaultSpotifyURL;
      _midsSameKey = prefs.getBool(_midsSameKeyKey) ?? _defaultMidsSameKey;
    });
    return 1;
  }

  @override
  Widget build(BuildContext context) {

    final settingsWidgets = <Widget>[
      Container(
        height: 50,
        child: ElevatedButton (
          style: ButtonStyle (
            backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
          ),
          child: Text("Reset to Defaults", textScaleFactor: 1.25,),
          onPressed: (){
            setState((){
              _setlistLength = _defaultSetlistLength;
              _wksBeforeReuse = _defaultWksBeforeReuse;
              _spotifyURL = _defaultSpotifyURL;
              _midsSameKey = _defaultMidsSameKey;
            });
          },
        ),
      ),

      ListTile(
        contentPadding: EdgeInsets.all(_pad),
        title: Text("Songs per setlist", textScaleFactor: 1.2,),
        subtitle: Text(_setlistLength.toString()),
        onTap: () => _showSetlistLengthPicker(context),
      ),

      ListTile(
        contentPadding: EdgeInsets.all(_pad),
        title: Text("Weeks before reusing song", textScaleFactor: 1.2,),
        subtitle: Text(_wksBeforeReuse.toString()),
        onTap: () => _showWksBeforeReusePicker(context),
      ),

      ListTile(
        contentPadding: EdgeInsets.all(_pad),
        title: Text("Spotify URL", textScaleFactor: 1.2,),
        subtitle: Text(_spotifyURL ?? "Error"),
        onTap: (){
          final editURL = SimpleDialog(
            title: Text("Edit Spotify URL"),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  minLines: 2,
                  maxLines: 5,
                  controller: _spotifyURLInput,
                  onEditingComplete: (){
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    hintText: "Spotify URL",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[700]),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelText: "Spotify URL",
                  ),
                ),
              ),

              Row(
                children: <Widget>[
                  TextButton (
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  TextButton (
                    child: Text("OK"),
                    onPressed: (){
                      setState((){_spotifyURL = _spotifyURLInput.text;});
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
          showDialog(
            context: context,
            builder: (context) {return editURL;},
            barrierDismissible: true,
          );
        },
      ),

      Row(
        children: <Widget>[
          Checkbox(
            //TODO: Uncomment these when I decide to implement this feature
            value: false,//_midsSameKey ?? false,
            onChanged: null,//(newVal){setState((){_midsSameKey = newVal;});},
          ),

          Expanded(
            child: TextButton (
              child: Text("Middle songs in the same key\n(Coming Soon!)"),
              onPressed: null,//(){setState((){_midsSameKey = !_midsSameKey;});},
            ),
          ),
        ],
      ),

      SizedBox(height: _pad*3,),

      Container(
        height: 45,
        child: ElevatedButton (
          style: ButtonStyle (
            padding: MaterialStateProperty.all(EdgeInsets.all(_pad)),
            backgroundColor: MaterialStateProperty.all(Colors.red)
          ),
          child: Text("Logout"),
          onPressed: () => turnOffAdmin(context),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle, textScaleFactor: 1.1,),),
      body: WillPopScope(
        onWillPop: () async {
          if (await _checkChanges()) {
            return await _promptSave();
          }
          return true;
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
      
      //Done button submits changes.
      //Every other way of exiting must ask
      // "Do you want to save changes?"
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        heroTag: null,
        tooltip: "Done",
        onPressed: (){_saveSettings(); Navigator.pop(context);},
      ),
    );
  }

  Future<bool> _checkChanges() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Read the settings for current saved values
    if(_setlistLength != prefs.getInt(_setlistLengthKey) ||
      _wksBeforeReuse != prefs.getInt(_wksBeforeReuseKey) ||
      _spotifyURL != prefs.getString(_spotifyURLKey) ||
      _midsSameKey != prefs.getBool(_midsSameKeyKey))
      return true;
    return false;
  }
  
  Future<bool> _promptSave() async {
    SimpleDialog promptForOverwrite = SimpleDialog(
      contentPadding: EdgeInsets.all(_pad),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10.0))),
      title: Center(child: Text('Save Changes?')),
      children: <Widget>[
        Center(child: Text("Do you want to save your changes?"),),
        SizedBox(height: 4,),

        Row(
          children: <Widget>[
            TextButton (
              child: Text("No"),
              onPressed: (){Navigator.pop(context, true);},
            ),

            Spacer(),

            TextButton (
              child: Text("Yes"),
              onPressed: () {_saveSettings(); Navigator.pop(context, true);},
            ),
          ],
        ),
      ],
    );

    return await showDialog<bool>(
      context: context,
      builder: (context){ return promptForOverwrite; },
      barrierDismissible: true,
    ) ?? false;
  }
  
  Future _saveSettings() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_setlistLengthKey, _setlistLength);
    await prefs.setInt(_wksBeforeReuseKey, _wksBeforeReuse);
    await prefs.setString(_spotifyURLKey, _spotifyURL);
    await prefs.setBool(_midsSameKeyKey, _midsSameKey);
  }

  Future _showSetlistLengthPicker(BuildContext context) async {
    await showDialog<int>(
      context: context,
      builder: (context){
        return NumberPicker ( //TODO fix number picker dialog
          onChanged: (int) {},
          minValue: 1,
          maxValue: 8,
          step: 1,
          value: _setlistLength,
        );
      },
    ).then((num value){
      if(value != null){
        setState((){_setlistLength = value;});
      }
    });
  }

  Future _showWksBeforeReusePicker(BuildContext context) async {
    await showDialog<int>(
      context: context,
      builder: (context){
        return NumberPicker ( //TODO fix number picker dialog
          onChanged: (int) {},
          minValue: 1,
          maxValue: 8,
          step: 1,
          value: _wksBeforeReuse,
        );
      },
    ).then((num value){
      if(value != null){
        setState((){_wksBeforeReuse = value;});
      }
    });
  }
}