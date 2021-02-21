import 'package:chat/Model/usersModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebaseService.dart';
import 'recentChat.dart';
import 'SharedPreference.dart';
import 'package:localstorage/localstorage.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  TextEditingController _userIdController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool showError = false;
  bool isSignUp = false;
  String userName;
  bool is_valid = false;
  LocalStorage localStorage = new LocalStorage('isLoggedIn');
  LocalStorage localStoragePhoneNumber = new LocalStorage('phone_number');

  @override
  Widget build(BuildContext context) {
    final phoneNumber = TextField(
      controller: _userIdController,
      keyboardType: TextInputType.phone,
//      obscureText: true,
      style: style,
      onChanged: (text) {
        setState(() {
          showError = false;
        });
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Enter Mobile Number",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final userName = TextField(
      controller: _userNameController,
      style: style,
      onTap: () {
        setState(() {
          showError = false;
        });
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Enter User Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    //Sign Up
    final signUp = FlatButton(
      child: new Text(
        "Sign Up",
        style: TextStyle(color: Colors.blueAccent),
      ),
      onPressed: () {
        setState(() {
          isSignUp = !isSignUp;
        });
      },
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(visible: isSignUp, child: userName),
                SizedBox(
                  height: 35.0,
                ),
                phoneNumber,
                SizedBox(
                  height: 35.0,
                ),
                Visibility(
                    visible: showError,
                    child: Text(
                      "Enter value",
                      style: TextStyle(color: Colors.red),
                    )),
                SizedBox(
                  height: 35.0,
                ),
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color(0xff01A0C7),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: () async {
                      if (_userIdController.text.length < 10) {
                        setState(() {
                          showError = true;
                        });
                      } else {
                        setState(() {
                          localStorage.setItem("isLoggedIn", true);
                          localStoragePhoneNumber.setItem(
                              "phone_number", _userIdController.text);
                          SharedPreference.addPhoneNumberToSF(
                              _userIdController.text);
                          SharedPreference.addUserNameToSF(
                              _userNameController.text);
                          if (isSignUp) {
                            if (_userIdController.text.length >= 10) {
                              FireBaseService.addUserToFirebase(
                                  _userIdController.text,
                                  _userNameController.text);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return RecentChatPage(_userIdController.text);
                              }));
                            }
                          } else {
                            FirebaseFirestore.instance
                                .collection("/users")
                                .get()
                                .then((querySnapshot) {
                              querySnapshot.docs.forEach((result) {
                                result.data().forEach((key, value) {
                                  if (key == 'phone_number' &&
                                      value == _userIdController.text) {
                                    setState(() {
                                      is_valid = true;
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return RecentChatPage(
                                            _userIdController.text);
                                      }));
                                    });
                                  }
                                });
                              });
                            });
                          }
                        });
                      }
                    },
                    child: Text(isSignUp ? "Register" : "Login",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                signUp
              ],
            ),
          ),
        ),
      ),
    );
  }
}
