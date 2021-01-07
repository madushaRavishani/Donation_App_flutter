import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String id,name,comment;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();

  Card buildItem(DocumentSnapshot doc) {
    return Card(
        margin: EdgeInsets.symmetric(vertical : 19, horizontal: 1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
             ),
          child: SingleChildScrollView(
            child: ListTile(
              title: Column(
                children: <Widget>[
                  Row(
                    children:<Widget> [
                       Icon(Icons.account_circle,color: Colors.yellow,),
                        Text('${doc.data()['name']}'),
                     ],
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Icon(Icons.message,color: Colors.red,),
                      Text('${doc.data()['comment']}'),
                     ],
                  )
            ],
                 ),
          ),
          ),
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
                onPressed: createData,
                child: Text('Submit'),
              )),
          StreamBuilder<QuerySnapshot>(
            stream: db.collection('comments').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: snapshot.data.documents.map((doc) => buildItem(doc)).toList());
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
      DocumentReference ref = await db.collection('comments').add({'name': '$name','comment': '$comment'});
      setState(() => id = ref.documentID);
      print(ref.documentID);
    }
  }

  void readData() async {
    DocumentSnapshot snapshot = await db.collection('comments').document(id).get();
    print(snapshot.data()['name']);
  }

  Widget buildBody(BuildContext context){

    return StreamBuilder<QuerySnapshot>(
      stream:db.collection('comments').snapshots(),
      builder: (context,snapshot){
        if (snapshot.hasData) {
          return Column(children: snapshot.data.documents.map((doc) => buildItem(doc)).toList());
        } else {
          return Container();
        }
      },
    );
  }

}