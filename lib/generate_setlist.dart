//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

//File imports
import 'song.dart';
import 'song_list.dart';
import 'settings_page.dart' as mySettings;
import 'authentication.dart';
import 'login_page.dart';
import 'nav_service.dart';

class GenerateSetlist extends StatefulWidget{
  GenerateSetlist({Key key, this.admin}) : super(key: key);

  final bool admin;

  @override
  _GenerateSetlistState createState() => _GenerateSetlistState();
}

final String pageTitle = "Generate Setlist";
enum SongType { begin, mid, end }

class _GenerateSetlistState extends State<GenerateSetlist>{
  final mainReference = FirebaseFirestore.instance.collection('song-list');
  final setlistReference = FirebaseFirestore.instance.collection('past-setlists');
  List<Song> songList = List<Song>();
  List<Song> setlist = List<Song>();
  List<Song> invalidSongs = List<Song>();
  bool _songListPopulated = false;

  final String _setlistLengthKey = 'setlist_length';
  final String _wksBeforeReuseKey = 'wks_before_reuse';
  final String _midsSameKeyKey = 'mid_same';

  final int _defaultSetlistLength = 4;
  final int _defaultWksBeforeReuse = 4;
  final bool _defaultMidsSameKey = false;
  final double _pad = 10;
  int _setlistLength;
  int _wksBeforeReuse;
  bool _midsSameKey;

  @override
  void initState(){
    super.initState();
    //Read the settings
    _readSetlistLength().then((len) => setState(() => _setlistLength = len));
    _readWksBeforeReuse().then((wk) => setState(() => _wksBeforeReuse = wk));
    _readMidsSameKey().then((mid) => setState(() => _midsSameKey = mid));
    //Populate the song list
    _getSongList().then((done){
      setState((){
        setlist = _buildSetlist(songList);
        _songListPopulated = true;
      });
    });
  }

  Future<int> _readSetlistLength() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_setlistLengthKey) ?? _defaultSetlistLength;
  }

  Future<int> _readWksBeforeReuse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wksBeforeReuseKey) ?? _defaultWksBeforeReuse;
  }

  Future<bool> _readMidsSameKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_midsSameKeyKey) ?? _defaultMidsSameKey;
  }

  Future<bool> _getSongList() async{
    await mainReference.get().then((contentsOfSongList){
      for(int i = 0; i < contentsOfSongList.docs.length; i++){
        DocumentSnapshot song = contentsOfSongList.docs[i];
        songList.add(new Song(
            song.id,
            song.get('key'),
            song.get('major'),
            song.get('begin'),
            song.get('mid'),
            song.get('end')
        ));
      }
    });
    await setlistReference.get().then((pastSetlists){
      int theRange = min(pastSetlists.docs.length, _wksBeforeReuse);
      for(int i = 1; i <= theRange; i++){
        DocumentSnapshot setlist = pastSetlists.docs[pastSetlists.docs.length-i];
        for(int j = 1; j <= setlist.data().length; j++){
          String lookup = "song" + j.toString();
          invalidSongs.addAll(songList.where((s) => s.title == setlist.get(lookup)));
        }
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
        actions: widget.admin ? <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => navToPage(context, mySettings.Settings()),
          ),
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            iconSize: 32,
            onPressed: () =>
                navToPage(context,
                    LoginSignUpPage(auth: Auth(),
                      onSignedIn: () =>  turnOnAdmin(context,
                      GenerateSetlist(admin: true)),)),
          ),
        ],
      ),

      body: Container(
        alignment: Alignment(0,0),
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

        child: _songListPopulated ? ListView.builder(
            itemBuilder: (context, index){
              return _displaySetlist(setlist, context, index);
            },
            itemCount: _setlistLength,
        ) : SizedBox(
          child: CircularProgressIndicator(),
          height: 150,
          width: 150,
        ),
      ),

      floatingActionButton: widget.admin? FloatingActionButton.extended(
        icon: Icon(Icons.done_outline),
        label: Text("Use This Setlist",
          textScaleFactor: 1.6,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        heroTag: null,
        tooltip: "Use Setlist",
        onPressed: () async {
          //Generate timestamp for next Wednesday (YYYYMMDD)
          DateTime today = DateTime.now();
          //Get today's DOW and number of days til Wednesday
          int daysTilWed = DateTime.wednesday - today.weekday;
          if(daysTilWed < 0 || (daysTilWed == 0 && today.hour >= 18))
            daysTilWed += 7;
          DateTime nextWed = today.add(Duration(days: daysTilWed));
          String nextWedStamp = nextWed.year.toString().padLeft(4, '0')
              + nextWed.month.toString().padLeft(2, '0')
              + nextWed.day.toString().padLeft(2, '0');

          //Check to see if next Wednesday already has a setlist
          DocumentSnapshot snap = await setlistReference.doc(nextWedStamp).get();
          if(snap.data != null){
            //If one exists, prompt for overwrite
            SimpleDialog promptForOverwrite = SimpleDialog(
              contentPadding: EdgeInsets.all(_pad),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0))),
              title: Container(),
              children: <Widget>[
                //TODO: Review the layout of this dialog and see if it's okay.
                Center(child: Text("A setlist already exists for\n" + _createDateOfNextWed(nextWedStamp) + ".\n",
                  textAlign: TextAlign.center, textScaleFactor: 1.2,),),
                Center(child: Text("Replace this setlist?", textScaleFactor: 1.2,),),

                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("No", textScaleFactor: 1.25,
                        style: TextStyle(
                        color: Colors.blue[600],
                      ),),
                      onPressed: () => Navigator.pop(context),
                    ),

                    Spacer(),

                    FlatButton(
                      child: Text("Yes", textScaleFactor: 1.25,
                          style: TextStyle(
                            color: Colors.blue[600],
                          ),),
                      onPressed: () => _submitSetlist(nextWedStamp),
                    ),
                  ],
                ),
              ],
            );

            showDialog(
              context: context,
              builder: (context){ return promptForOverwrite; },
            );
          }
          else
            _submitSetlist(nextWedStamp);
        },
      ) :
      FloatingActionButton.extended(
        onPressed: null,
        heroTag: null,
        label: Text("Please sign in to save a setlist.",
        textScaleFactor: 1.3,),
        backgroundColor: Colors.blueGrey[400],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListTile _displaySetlist(List<Song> songsInSetlist,
      BuildContext context, int index){
    Song s = songsInSetlist[index];

    return ListTile(
      leading: CircleAvatar(child: Text((index+1).toString())),
      title: Text(s.title),
      subtitle: Text(s.key + " " + (s.major ? "major" : "minor")),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        tooltip: "Edit",
        onPressed: () async {
          Song s = await navToPageWithResult(context, SongList(admin: widget.admin, select: true)) as Song;
          if(s != null){
            setState((){
              songsInSetlist[index] = s;
            });
          }
        },
      ),
      onLongPress: (){
        if(index == 0)
          _rerollOneSong(index, SongType.begin);
        else if(index == setlist.length-1)
          _rerollOneSong(index, SongType.end);
        else
          _rerollOneSong(index, SongType.mid);
      },
    );
  }

  List<Song> _buildSetlist(List<Song> allSongs) {
    List<Song> setlist = List<Song>();
    //Create random generator
    Random gen = Random.secure();

    //Populate first song
    while(allSongs.length > 0){
      int rand = gen.nextInt(allSongs.length);
      Song tryThis = allSongs[rand];
      if(tryThis.begin && !invalidSongs.contains(tryThis)){
        setlist.add(tryThis);
        break;
      }
      else
        print("begin rejected " + tryThis.toString());
    }
    //Populate middle songs
    int numMid = 0;
    String midKey;
    for(int i = 1; i < _setlistLength-1; i++)
      while(allSongs.length > 0){
        if(numMid == 1 && _midsSameKey){
          midKey = setlist[1].key;
          print(midKey);
          //See if enough other songs exist of the same key
          if(songList.where((s) =>
            s.mid && s.key == midKey && s.title != setlist[1].title).length < _setlistLength-2){
            setlist.removeAt(1);
            i--;
            numMid = 0;
          }
        }
        int rand = gen.nextInt(allSongs.length);
        Song tryThis = allSongs[rand];
        if (tryThis.mid && !setlist.contains(tryThis) && !invalidSongs.contains(tryThis)) {
          //TODO: Check the key and if the mids need to be the same key (semi-stretch goal)
          setlist.add(tryThis);
          numMid++;
          break;
        }
        else
          print("mid rejected " + tryThis.toString());
      }
    //Populate last song
    while(allSongs.length > 0){
      int rand = gen.nextInt(allSongs.length);
      Song tryThis = allSongs[rand];
      if(tryThis.end && !setlist.contains(tryThis) && !invalidSongs.contains(tryThis)){
        setlist.add(tryThis);
        break;
      }
      else
        print("end rejected " + tryThis.toString());
    }
    //for(int i = 0; i < setlist.length; i++){
    //  print(setlist[i].toString());
    //}
    return setlist;
  }

  void _rerollOneSong(int index, SongType type){
    //Create random generator
    Random gen = Random.secure();
    while(true){
      int rand = gen.nextInt(songList.length);
      Song tryThis = songList[rand];
      if(!setlist.contains(tryThis) && !invalidSongs.contains(tryThis) && tryThis.title != setlist[index].title){
        if(type == SongType.begin && tryThis.begin){
          setState((){setlist[index] = tryThis;});
          break;
        }
        else if(type == SongType.mid && tryThis.mid){
          setState((){setlist[index] = tryThis;});
          break;
        }
        else if(type == SongType.end && tryThis.end){
          setState((){setlist[index] = tryThis;});
          break;
        }
        else
          print("reroll rejected " + tryThis.toString());
      }
      else
        print("reroll rejected " + tryThis.toString());
    }
  }

  Future _submitSetlist(String docID) async {
    //Show circular progress indicator
    setState((){_songListPopulated = false;});
    //Push a setlist as a new document in the database
    List<String> songNums = new List<String>();
    List<String> songNames = new List<String>();
    for(int i = 0; i < setlist.length; i++){
      songNums.add("song" + (i+1).toString());
      songNames.add(setlist[i].title);
    }
    Map<String, String> data = Map.fromIterables(songNums, songNames);
    await setlistReference.doc(docID).set(data);
    //Nav back to landing page
    navToLandingPage(context);
  }

  String _createDateOfNextWed(String unformatted){
    int month = int.tryParse(unformatted.substring(4,6));
    String day = unformatted.substring(6);
    String year = unformatted.substring(0,4);
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
}