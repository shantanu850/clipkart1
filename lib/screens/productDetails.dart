import 'package:clipkart/screens/Cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class ProductDetails extends StatefulWidget {
  final snapshot;
  const ProductDetails({Key key, this.snapshot}) : super(key: key);
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  List images = [];
  bool added;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  initState(){
    super.initState();
    images = widget.snapshot.data['img'];
    added = false;
  }
  getFeed()async{
    QuerySnapshot snapshot = await Firestore.instance.collection("products").document(widget.snapshot.documentID).collection('feedbacks').getDocuments();
    return snapshot.documents;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: ListView(
          children: [
            Container(
              child:GFCarousel(
                height: 210,
                autoPlay: true,
                viewportFraction: 1.0,
                items: images.map(
                      (url) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      height:250,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal:10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                            Radius.circular(15.0)),
                        child: Image.network(
                          url,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(height:20),
            Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight:Radius.circular(15),
                        topLeft: Radius.circular(15)
                    )
                ),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(8.0),
                    child: Text(widget.snapshot.data['title'],
                      textAlign:TextAlign.start,
                      style: TextStyle(
                        fontSize:18,

                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width:47,
                        margin: EdgeInsets.only(left:18),
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child: Row(
                          children: [
                            Text(widget.snapshot.data['ratings'],
                              style:TextStyle(
                                backgroundColor: Colors.green,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width:2,),
                            Icon(Icons.star,color: Colors.white,size:15,),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8.0),
                        child: Text("Only : "+widget.snapshot.data['price']+" INR",
                          textAlign:TextAlign.start,
                          style: TextStyle(

                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height:120,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:widget.snapshot.data['colors'].length,
                        itemBuilder:(context,index){
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                images = widget.snapshot.data['colors'][index]['img'];
                              });
                            },
                            child: Container(
                                decoration:BoxDecoration(
                                  borderRadius:BorderRadius.all(Radius.circular(5)),
                                ),
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image(
                                        image: NetworkImage(widget.snapshot.data['colors'][index]['logo']),
                                        fit:BoxFit.fitHeight,
                                        height:80,
                                        width: 80,
                                    ),
                                    Text(widget.snapshot.data['colors'][index]['color']),
                                  ],
                                ),
                            ),
                          );
                        }
                    )
                  ),
                  ListTile(
                    title: Text("Features",style: TextStyle(fontWeight: FontWeight.bold),),
                    trailing: Text("view all",style: TextStyle(color: Colors.blue),),
                  ),
                  Column(
                      children: [
                        Container(
                              padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.07),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:widget.snapshot.data['features'].length,
                                  itemBuilder:(context,index){
                                    List title = widget.snapshot.data['features'][index].split("#");
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical:2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              child: Text(title[0],style: TextStyle(fontWeight: FontWeight.bold),),
                                            width: MediaQuery.of(context).size.width*0.35,
                                          ),
                                          Container(
                                              child: Text(title[1]),
                                            width: MediaQuery.of(context).size.width*0.50,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              ),
                            ),
                      ],
                    ),
                  ListTile(
                    title: Text("Ratings & Review"),
                    trailing:Text("Rate Product",style: TextStyle(color: Colors.blue),)
                  ),
                  Container(
                    child:FutureBuilder(
                      future:getFeed(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState != ConnectionState.waiting) {
                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Card(
                                        color: Colors.green,
                                        child: Text(
                                          snapshot.data[index].data['ratings'],
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                          snapshot.data[index].data['title']),
                                      subtitle: Text(snapshot.data[index]
                                          .data['description']),
                                    ),
                                  ],
                                );
                              }
                          );
                        }else{
                          return Container();
                        }
                      }
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          children: [
            (added==false)?GestureDetector(
              onTap:()async{
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                Firestore.instance.collection('user').document(user.uid).collection('mycart').document().setData({
                  'productId':widget.snapshot.documentID,
                  'time':Timestamp.now(),
                }).whenComplete(() => {
                  setState((){
                    added = true;
                  }),
                  _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("Added to cart"),
                  duration: Duration(seconds: 3),
                ))
                });
              },
              child: Container(
                height: 56,
                color: Colors.redAccent,
                alignment: Alignment.center,
                width:MediaQuery.of(context).size.width*0.5,
                child: Text("ADD TO CART",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              ),
            ):GestureDetector(
              onTap:()async{
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Cart()));
              },
              child: Container(
                height: 56,
                color: Colors.green,
                alignment: Alignment.center,
                width:MediaQuery.of(context).size.width*0.5,
                child: Text("GO TO CART",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              height: 56,
              alignment: Alignment.center,
              color: Colors.blue,
              width:MediaQuery.of(context).size.width*0.5,
              child: Text("BUY NOW",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}
