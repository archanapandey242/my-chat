import 'package:chat/recentChat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
//  await FirebaseApi.addRandomUsers(Users.initUsers);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoggedIn = false;
  String userName;
  String phoneNumber;
  LocalStorage localStorage = new LocalStorage('isLoggedIn');
  LocalStorage phoneNumberLocalStorage = new LocalStorage("phone_number");

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: localStorage.ready,
        builder: (BuildContext context, snapshot) {
          if (snapshot.data == true) {
            isLoggedIn = localStorage.getItem('isLoggedIn');
            phoneNumber = phoneNumberLocalStorage.getItem('phone_number');
            if(isLoggedIn==null) {
              return Login();
            }else{
              return isLoggedIn ? RecentChatPage(phoneNumber) : Login();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }


}
