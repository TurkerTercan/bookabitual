import 'dart:io';

import 'package:bookabitual/utils/avatarPictures.dart';
import 'package:bookabitual/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bookworm.dart';
import '../../states/currentUser.dart';

class EditProfile extends StatefulWidget {
  @override
  // ignore: missing_return
  State<StatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  TextEditingController _photoController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  int index;

  @override
  Widget build(BuildContext context) {
    Bookworm _currentUser = Provider.of<CurrentUser>(context).getCurrentUser;
    index = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text("bookabitual",
          style: TextStyle(
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).bottomAppBarColor,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: ListView(
              padding: EdgeInsets.all(30.0),
              children: <Widget>[
                editPhoto(_currentUser),
                addSpace(),
                changeName(_currentUser),
                addSpace(),
                SizedBox(height: 50, width: 30),
                saveChangedButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget editPhoto(Bookworm _currentUser) {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 90,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: Colors.blueGrey,
              ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(avatars[index]),
                  radius: 25.0,
                ),
            ),
            Expanded(
              child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width : 3.0),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 0;
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(avatars[0]),
                    radius: 40.0,
                  ),
                ),
                SizedBox(width : 3.0),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 1;
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(avatars[1]),
                    radius: 40.0,
                  ),
                ),
                SizedBox(width : 13.0),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      imageCache.clear();
                      index = 2;
                      print(index);
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(avatars[2]),
                    radius: 40.0,
                  ),
                ),
              ],
             ),
            ),
          ],
        ),
      ),
    );
  }


  Widget changeName(_currentUser) {
    return TextFormField(
        decoration: InputDecoration(labelText: "Name"),
        //  validator: validateFirstName,
        onSaved: (String value){
          if(value != null) {
            _currentUser.name = value;
          }
        }
    );
  }

  Widget addSpace() {
    return SizedBox(height: 30, width: 30);
  }

  Widget saveChangedButton() {
    return RaisedButton(
      onPressed: (){
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 100),
        child: Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}