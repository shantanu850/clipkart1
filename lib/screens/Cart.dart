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
  void initState() {
    sumi().sum();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("My Cart"),
      ),
      body: Container(
        child: ListView(
          children: [
            Container(
              child:FutureBuilder(
                future: getData() ,
                builder: (context, snapshot) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context,index){
                      if(snapshot.connectionState != ConnectionState.waiting){
                        return ListTile(
                          title: Doc(
                            doc: snapshot.data[index].data['productId'],
                            selected: 0,),
                        );
                      }else{
                        return Container();
                      }
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 56,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(sumi().total.toString()),
            Text("Pay",style: TextStyle(color:Colors.blue),)
          ],
        ),
      ),
    );
  }
}
class sumi{
  int total;
  List list = [];
  sum(){
    for(int i=0;i<list.length;i++){
      total = total + list[i];
    }
    print(total);
    return 0;
  }
}

class Doc extends StatefulWidget {
  final doc;
  final selected;
  const Doc({Key key, this.doc, this.selected}) : super(key: key);
  @override
  _DocState createState() => _DocState();
}

class _DocState extends State<Doc> {
  getProducts(doc)async{
    DocumentSnapshot snapshot  = await Firestore.instance.collection('products').document(doc).get();
    return snapshot;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getProducts(widget.doc),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            int val = snapshot.data['colors'][widget.selected]['price'];
            sumi().list.add(val);
            print("value is : " +snapshot.data['colors'][widget.selected]['price'].toString());
            return ListTile(
              leading: Image(image: NetworkImage(snapshot.data['image']),
                height: 100,
                fit: BoxFit.fitHeight,),
              title: Text(snapshot.data['title']),
              subtitle: Text(
                  snapshot.data['colors'][widget.selected]['price'].toString()),
            );
          }else{
            return Container();
          }
        }
      ),
    );
  }
}

