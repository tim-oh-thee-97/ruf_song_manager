//Package imports
import 'package:flutter/material.dart';

//File imports

class HelpPage extends StatefulWidget{
  HelpPage({Key key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

final String pageTitle = "Help";

class _HelpPageState extends State<HelpPage>{
  //TODO: Implement

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, textScaleFactor: 1.1,),
      ),
      body: Container(),
    );
  }
}