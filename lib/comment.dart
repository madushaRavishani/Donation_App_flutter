import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:notifications/home.dart';
import 'package:notifications/comment.dart';
import 'package:notifications/navbar.dart';

class Comments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Leave your Comments Here';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class, which holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.

  String id, name, comment;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: Colors.pink[50],
      margin:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.account_circle, size: 50),
            title: Text('${doc.data()['name']}'),
            subtitle: Text('${doc.data()['comment']}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.person),
              hintText: 'Enter your full name',
              labelText: 'Name',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onSaved: (value) => name = value,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.message),
              hintText: 'Enter Your comment',
              labelText: 'Comment',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onSaved: (value) => comment = value,
          ),
          new Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 5.0),
              child: new RaisedButton(
                onPressed: () {
                  createData;
                  showAlertDialog(context);
                },
                child: Text('Submit'),
              )),
          StreamBuilder<QuerySnapshot>(
            stream: db.collection('comments').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.documents
                        .map((doc) => buildItem(doc))
                        .toList());
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  void createData() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      DocumentReference ref = await db
          .collection('comments')
          .add({'name': '$name', 'comment': '$comment'});
      setState(() => id = ref.documentID);
      print(ref.documentID);
    }
  }

  void readData() async {
    DocumentSnapshot snapshot =
        await db.collection('comments').document(id).get();
    print(snapshot.data()['name']);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
