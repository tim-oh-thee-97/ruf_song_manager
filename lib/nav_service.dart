import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'landing_page.dart';
import 'authentication.dart';

final String _adminKey = 'are_you_admin';

void navToPage(BuildContext context, Widget widget) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => widget)
  );
}

Future<Object> navToPageWithResult(BuildContext context, Widget widget) async {
  final Object toReturn = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => widget)
  );
  return toReturn;
}

void navToLandingPage(BuildContext context){
  Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
}

void turnOnAdmin(BuildContext context, Widget widget, {bool pageOnTop = true}) async{
  final FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.write(key: _adminKey, value: "true");
  navToLandingPage(context);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
  if(pageOnTop)
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

void turnOffAdmin(BuildContext context) async{
  await Auth().signOut();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  await storage.write(key: _adminKey, value: "false");
  navToLandingPage(context);
  //Navigator.pop(context);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
}