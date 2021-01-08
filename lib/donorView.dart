import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';
import 'models/details.dart';

void main() =>runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'test',
      home: DonorView(),

    );
  }
}
class DonorView extends StatefulWidget {

  DonorView() : super();

  final String appTitle = "Details of Needy People";

  @override
  _DonorViewState createState() => _DonorViewState();
}

class _DonorViewState extends State<DonorView> {

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.appTitle),
        actions: <Widget>[
           IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: (){
              Navigator.push(context, new MaterialPageRoute(builder: (context)=> new MyApp()));
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
            Flexible(child: buildBody(context),)
          ],
        ),
      ),
    );

  }
}