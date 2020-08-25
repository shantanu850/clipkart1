import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  getData()async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot snapshot = await Firestore.instance.collection('user').document(user.uid).collection('mycart').getDocuments();
    return snapshot.documents;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("My Cart"),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              child:FutureBuilder(
                future: getData() ,
                builder: (context, snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context,index){
                      return ListTile(
                        title: Text(snapshot.data[index].data['productId']),
                        subtitle: Text(snapshot.data[index].data['time'].toString()),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
