import 'package:cloud_firestore/cloud_firestore.dart';

class Details{

  String name;
  String address;

  DocumentReference documentReference;

  Details({this.name,this.address});

  Details.fromMap(Map<String,dynamic>map,{this.documentReference}){

    name = map["name"];
    address = map["address"];
  }

  Details.fromSnapshot(DocumentSnapshot snapshot)
  :this.fromMap(snapshot.data(), documentReference:snapshot.reference);

  toJason(){
    return{'name':name, 'address':address};
    
  }
}