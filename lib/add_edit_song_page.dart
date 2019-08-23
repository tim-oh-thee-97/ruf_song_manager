//Package imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//File imports
import 'song.dart';
import 'settings_page.dart';
import 'nav_service.dart';

class AddEditSongPage extends StatefulWidget{
  AddEditSongPage({Key key, this.song}) : super(key: key);

  final Song song;

  @override
  _AddEditSongPageState createState() => _AddEditSongPageState();
}

class _AddEditSongPageState extends State<AddEditSongPage>{
  final mainReference = Firestore.instance.collection('song-list');

  final double _pad = 10.0;
  String _errorText;
  String _title, _key;
  bool _maj = true;
  bool _begin, _mid, _end;
  String _sharp;

  static List<String> _sharpFlat = <String>['  ', '\u{266F}', '\u{266D}'];
  static List<String> _possibleKeys = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  TextEditingController _titleInput = TextEditingController();
  TextEditingController _keyInput = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    _titleInput.dispose();
    _keyInput.dispose();
  }

  @override
  void initState(){
    super.initState();
    _errorText = null;
    if(widget.song == null){
      _title = null;
      _maj = true;
      _begin = false;
      _mid = false;
      _end = false;
      _sharp = _sharpFlat[0];
    }
    else{
      //Populate the fields with the given song
      _titleInput.text = widget.song.title;
      if(widget.song.key.length == 1){
        _keyInput.text = widget.song.key;
      }
      else {
        _keyInput.text = widget.song.key.substring(0, 1);
        if (widget.song.key.substring(1) == "#")
          _sharp = _sharpFlat[1];
        else if (widget.song.key.substring(1) == "b")
          _sharp = _sharpFlat[2];
        else
          _sharp = _sharpFlat[0];
      }
      _maj = widget.song.major;
      _begin = widget.song.begin;
      _mid = widget.song.mid;
      _end = widget.song.end;
    }
  }

  @override
  Widget build(BuildContext context){
    final _songForm = <Widget>[
      Text(_errorText ==  null ? "" : _errorText,
        textScaleFactor: 1.4,
        style: TextStyle(
          color: Colors.red,
          //fontStyle: FontStyle.italic,
        ),
      ),

      SizedBox(height: _pad),

      TextField(
        controller: _titleInput,
        onEditingComplete: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Song Title",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[700]),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelText: "Title",
        ),
      ),

      SizedBox(height: _pad,),

      Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: TextField(
              controller: _keyInput,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Key",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange[700]),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                labelText: "Key",
                counterText: "",
              ),
              maxLength: 1,
              maxLengthEnforced: true,
            ),
          ),

          SizedBox(width: _pad*2,),

          _sharpFlatDropdown(),

          Spacer(),

          FlatButton(
            child: Text(_maj ? "Major" : "Minor", textScaleFactor: 1.2,),
            onPressed: (){setState((){_maj = !_maj;});},
          ),
          Checkbox(
            value: _maj,
            onChanged: (bool newVal){
              setState((){_maj = newVal;});
            },
          ),
        ],
      ),

      SizedBox(height: _pad*2,),

      Text("Tags:", textScaleFactor: 1.75,
        style: TextStyle(fontWeight: FontWeight.bold),),

      Row(
        children: <Widget>[
          Checkbox(
            value: _begin,
            onChanged: (bool newVal) {
              setState((){_begin = newVal;});
            },
          ),
          FlatButton(
            child: Text("Begin", textScaleFactor: 1.25,),
            onPressed: (){setState((){_begin = !_begin;});},
          ),
        ],
      ),

      Row(
        children: <Widget>[
          Checkbox(
            value: _mid,
            onChanged: (bool newVal) {
              setState(() {
                _mid = newVal;
              });
            },
          ),
          FlatButton(
            child: Text("Middle", textScaleFactor: 1.25,),
            onPressed: (){setState((){_mid = !_mid;});},
          ),
        ],
      ),

      Row(
        children: <Widget>[
          Checkbox(
            value: _end,
            onChanged: (bool newVal) {
              setState((){_end = newVal;});
            },
          ),
          FlatButton(
            child: Text("End", textScaleFactor: 1.25,),
            onPressed: (){setState((){_end = !_end;});},
          ),
        ],
      ),

      SizedBox(height: _pad*5,),

      widget.song != null ?
      Container(
        height: 40,
        child: RaisedButton(
          color: Colors.redAccent,
          child: Text("Delete Song"),
          onPressed: () async {
            SimpleDialog deleteConfirmation = SimpleDialog(
              contentPadding: EdgeInsets.all(_pad),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0))),
              title: Center(child: Text('Proceed?')),
              children: <Widget>[
                Center(child: Text("Are you sure you want to delete this song?"),),
                SizedBox(height: 4,),

                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: (){Navigator.pop(context);},
                    ),

                    Spacer(),

                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        mainReference.document(widget.song.title).delete();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            );

            return await showDialog<bool>(
              context: context,
              builder: (context){ return deleteConfirmation; },
              barrierDismissible: true,
            ) ?? false;
          },
        ),
      ) : Container(),
    ];

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.song == null ? 'Add New Song' : 'Edit Song', textScaleFactor: 1.1,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            iconSize: 32,
            onPressed: () => navToPage(context, Settings()),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/willingham.jpg"),
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
                children: _songForm,
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        heroTag: null,
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Widget _sharpFlatDropdown(){
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton<String>(
          value: _sharp,
          isDense: true,
          onChanged: (String newValue) {
            setState(() {
              _sharp = newValue;
            });
          },
          items: _sharpFlat.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _validateAndSubmit() async {
    setState((){
      _title = _titleInput.text.trim();
      _key = _keyInput.text.trim().toUpperCase();
      _title = _fixCapitalization(_title);
    });
	  DocumentSnapshot thisSong = await mainReference.document(_title).get();
	
    if(_title == null || _title.isEmpty)
      setState((){_errorText = "Please input a title.";});
    else if(_key == null || _key.isEmpty)
      setState((){_errorText = "Please input a key.";});
    else if(!_possibleKeys.contains(_key))
      setState((){_errorText = "Please input a valid key (A-G).";});
    else if(!_begin && !_mid && !_end)
      setState((){_errorText = "Please select one or more tags.";});
    else if(widget.song == null && thisSong.data != null){
      setState((){_errorText = "This song already exists.";});
    }
    else{
	  //Append sharp or flat to key
	  switch(_sharp){
	    case '\u{266F}':
		  _key += '#';
		  break;
		case '\u{266D}':
		  _key += 'b';
		  break;
		default:
		  break;
	  }
	  
      //Submit the song
      Song s = new Song(
        _title,
        _key,
        _maj,
        _begin,
        _mid,
        _end
      );
      await mainReference.document(_title).setData(s.toJson());
      Navigator.pop(context);
    }
  }

  String _fixCapitalization(String s){
    List<String> words = s.toLowerCase().split(" ");
    final List<String> dontCap = ["a", "an", "the",
      "and", "but", "or", "nor", "for",
      "with", "in", "on", "at", "to", "from", "by", "as", "of"];
    //Always capitalize first and last
    words[0] = _capitalize(words[0]);
    words[words.length-1] = _capitalize(words[words.length-1]);

    for(int i = 1; i < words.length-1; i++){
      if(!dontCap.contains(words[i]))
        words[i] = _capitalize(words[i]);
    }
    return words.join(" ");
  }

  String _capitalize(String s){
    if(s.isNotEmpty){
      if(s.length == 1)
        return s.toUpperCase();
      else
        return s.substring(0,1).toUpperCase() + s.substring(1).toLowerCase();
    }
    else
      return "";
  }
}