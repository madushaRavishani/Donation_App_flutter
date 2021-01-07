import 'package:flutter/material.dart';
import 'package:notifications/home.dart';
import 'package:notifications/comment.dart';
import 'package:notifications/login.dart';

import 'image.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Donation App',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new FirestoreCRUDPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Login'),
            onTap: () => {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MyLoginPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Our Services'),
            onTap: () => {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          new UploadingImageToFirebaseStorage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => new Comments()))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
