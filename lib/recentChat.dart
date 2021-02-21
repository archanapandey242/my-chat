import 'package:chat/Model/dateAndTime.dart';
import 'package:chat/chatDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebaseService.dart';
import 'package:chat/Model/usersModel.dart';

import 'login.dart';

class RecentChatPage extends StatefulWidget {
  String userId;
  RecentChatPage(this.userId);

  @override
  _RecentChatPageState createState() => _RecentChatPageState();
}

class _RecentChatPageState extends State<RecentChatPage> {
  ScrollController _scrollController = new ScrollController();
  TextEditingController _userController = new TextEditingController();
  TextEditingController _userIdController = new TextEditingController();

  bool isLoading = false;
  int currentMax = 10;
  String phoneNumber;

  @override
  void initState() {
    super.initState();
    getPhoneNumber();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {}
      });

  }

  getPhoneNumber() async {
    SharedPreferences phoneNumberPrefs = await SharedPreferences.getInstance();
    phoneNumber = phoneNumberPrefs.getString('phone_number');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Recent Chat"),
            InkWell(child: Text("Logout"),onTap: (){
              Navigator.of(context).push(MaterialPageRoute<Login>(
                  builder: (BuildContext context) {
                    return Login();
                  }));
            },)
          ],
        ),
      ),
      body: showRecentChat(),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showRecentChat() {
    return Center(
      child: Container(
        child: StreamBuilder<List<User>>(
            stream: FireBaseService.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  print("snapshot.hasdata---------------${snapshot}");

                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Visibility(
                            visible: returnUserList(snapshot.data, index)!="",
                            child: ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ChatDetails(
                                      userName: snapshot.data[index].name,
                                      userId: snapshot.data[index].idUser,uniqueId:returnUniqueId(snapshot.data[index].idUser,this.widget.userId));
                                }));
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5, top: 5),
                                    child: Container(
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: new BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text(returnUserList(
                                                snapshot.data, index),textAlign: TextAlign.start,),
                                          ),
                                          Spacer(),
                                          Text(DateAndTime.getDisplayDateNotes(snapshot.data[index].lastMessageTime.toString()),textAlign: TextAlign.right,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
              }
            }),
      ),
    );
  }

  //--------------------Dialog box for adding username and phone number----------------
  addUserToFirebase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Add Users"),
          content: Column(
            children: <Widget>[
              TextField(
                controller: _userController,
                onSubmitted: (value) {},
                autofocus: false,
                onTap: () {},
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Add UserName",
                  filled: false,
                  focusedBorder: InputBorder.none,
                ),
              ),
              TextField(
                controller: _userIdController,
                onSubmitted: (value) {},
                autofocus: false,
                onTap: () {},
                keyboardType: TextInputType.phone,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Add Phone Number",
                  filled: false,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Add"),
              onPressed: () {
                if (_userIdController.text.length >= 10) {
                  FireBaseService.addUserToFirebase(
                      _userIdController.text, _userController.text);
                  Navigator.of(context).pop();
                } else {}
              },
            ),
          ],
        );
      },
    );
  }

  String returnUserList(
    List<User> userData,
    int index,
  ) {
    String userName;
    if (userData[index].idUser != phoneNumber) {
      userName = userData[index].name;
    }else{
      userName = "";
    }
    return userName;
  }

  String returnUniqueId(String receiverId, String senderId) {
    String idUserValue ;
    if(int.parse(phoneNumber)>int.parse(receiverId)){
      idUserValue = phoneNumber + "_" + receiverId;
    }else{
      idUserValue = receiverId + "_" + phoneNumber;
    }
    return idUserValue;
  }
}
