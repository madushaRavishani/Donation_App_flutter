import 'package:flutter/material.dart';
//import 'package:notifications/home.dart';
import 'package:notifications/comment.dart';
import 'HelpHands.dart';
import 'image.dart';
import 'load.dart';
import 'login.dart';

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
                color: Colors.lightBlue,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: () => {
              Navigator.push(context, new MaterialPageRoute(builder: (context)=> new LoadFirbaseStorageImage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Details'),
            onTap: () => {
              Navigator.push(context, new MaterialPageRoute(builder: (context)=> new HelpHands()))
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Our Services'),
            onTap: () => {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new UploadingImageToFirebaseStorage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {
              Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Comments()))
            },
          ),

        ],
      ),
    );
  }
}

