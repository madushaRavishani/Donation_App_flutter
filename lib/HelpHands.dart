import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/details.dart';

class HelpHands extends StatefulWidget {

  HelpHands() : super();

  final String appTitle = "Your Details";

  @override
  _HelpHandsState createState() => _HelpHandsState();
}

class _HelpHandsState extends State<HelpHands> {

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message){
        showNotification(message);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message){
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message){
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'message',
      "Title",
      "Body",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, "Donation App", "You have updated details successfully", platform);
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isEditing= false;
  bool textFielsVisibility = false;

  String firestoreCollectionName ="Details";

  Details currentDetails;

  getAllDetails(){   //get all details

    return Firestore.instance.collection(firestoreCollectionName).snapshots();

  }

  addDetails() async {    //add details

    Details details = Details(name: nameController.text, address: addressController.text);

    try{

      Firestore.instance.runTransaction(
              (Transaction transaction) async{

            await Firestore.instance
                .collection(firestoreCollectionName)
                .document()
                .setData(details.toJason());

          }

      );

    }
    catch (e){
      print(e.toString());

    }

  }
  //update details

  updateDetails(Details details, String name,String address){

    try{

      Firestore.instance.runTransaction((transaction) async{

        await transaction.update(details.documentReference, {'name':name, 'address':address});

      });

    }
    catch(e){
      print(e.toString());

    }

  }

  updateIfEditing(){
    if(isEditing){
      //update
      updateDetails(currentDetails, nameController.text, addressController.text);

      setState(() {
        isEditing = false;
      });
    }
  }

  //delete details
  deleteDetails(Details details){
    Firestore.instance.runTransaction(
            (Transaction transaction) async{
          await transaction.delete(details.documentReference);
        });
  }


  Widget buildBody(BuildContext context){

    return StreamBuilder<QuerySnapshot>(
      stream: getAllDetails(),
      builder: (context,snapshot){
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}'); //show the error
        }
        if(snapshot.hasData){
          print("Documents -> ${snapshot.data.documents.length}");
          return buildList(context,snapshot.data.documents);
        }else{
          return Container();
        }

      },
    );
  }

//build List
  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      children: snapshot.map((data) => listItemBuild(context,data)).toList(),
    );
  }

  Widget listItemBuild(BuildContext context, DocumentSnapshot data){

    final details = Details.fromSnapshot(data);

    return Padding(
      key: ValueKey(details.name),
      padding: EdgeInsets.symmetric(vertical : 19, horizontal: 1),
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
                    Icon(Icons.person,color: Colors.yellow,),
                    Text(details.name),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Icon(Icons.person,color: Colors.red,),
                    Text(details.address),

                  ],
                )
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: (){
                deleteDetails(details);
              },
            ),
            onTap: (){
              setUpdateUI(details);
            },
          ),
        ),
      ),
    );
  }

  setUpdateUI(Details details){

    nameController.text=details.name;
    addressController.text=details.address;

    setState(() {
      textFielsVisibility = true;
      isEditing = true;
      currentDetails=details;
    });
  }

  button(){
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        child: Text(isEditing ? "UPDATE" : "ADD"),
        onPressed: (){
          if(isEditing == true){
            updateIfEditing();
          }else{
            addDetails();
          }
          setState(() {
            textFielsVisibility= false;
          });
        } ,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,

      appBar: AppBar(
        title: Text(widget.appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              setState(() {
                textFielsVisibility =!textFielsVisibility;

              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            textFielsVisibility
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                          labelText: "Full Name",
                          hintText: "Enter Name"
                      ),
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                          labelText: "Address",
                          hintText: "Enter Address"
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height:10,
                ),
                button()

              ],
            ): Container(),
            SizedBox(
              height: 20,
            ),
            Text("Details",style:TextStyle(
                fontSize:18,
                fontWeight: FontWeight.w800
            ),),
            SizedBox(
              height: 20,
            ),
            Flexible(child: buildBody(context),)


          ],
        ),


      ),

    );

  }
}