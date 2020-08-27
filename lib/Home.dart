import 'package:clipkart/main.dart';
import 'package:clipkart/screens/Cart.dart';
import 'package:clipkart/screens/productDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:getwidget/getwidget.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List img;
  FirebaseUser user;
  List imgBk = [
      "https://i.pinimg.com/originals/6c/b4/fb/6cb4fb8096bf0c0f7202bfff3bb2f55f.jpg",
    "https://graphicgoogle.com/wp-content/uploads/2018/01/Special-Offer-Facebook-Ad-Banner-Template-1200x627.jpg",
  ];
  getTop()async{
    QuerySnapshot snapshot = await Firestore.instance.collection("products").getDocuments();
    return snapshot.documents;
  }
  getAds()async{
    DocumentSnapshot snapshot = await Firestore.instance.collection('adds').document('mobile').get();
    return snapshot;
  }
  getCat()async{
    QuerySnapshot snapshot = await Firestore.instance.collection('category').getDocuments();
    return snapshot.documents;
  }
  getCart()async{
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot snapshot = await Firestore.instance.collection('user').document(_user.uid).collection('mycart').getDocuments();
    return snapshot.documents;
  }
  @override
  void initState() {
    getAds();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: ListView(
            children: [
              Container(
                height: 100,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://pixinvent.com/demo/vuexy-vuejs-admin-dashboard-template/demo-3/img/user-13.005c80e1.jpg"),
                  ),
                  title: Text("User",style:TextStyle(color: Colors.white),),
                  subtitle: Text("default@mail.com",style:TextStyle(color: Colors.white),),
                  trailing: IconButton(icon:Icon(Icons.power_settings_new,color:Colors.white,),
                      onPressed:(){
                        FirebaseAuth.instance.signOut().whenComplete(() => {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>MyHomePage()))
                    });
                  }),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left:10.0),
                child: ListTile(
                  onTap:(){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Cart()));
                  },
                  title: Row(
                    children: [
                      Icon(Icons.shopping_cart,color:Colors.white,),
                      SizedBox(width:10),
                      Text("Cart",style:TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder:(BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: Colors.black,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite_border,color: Colors.white,),
              ),
              GFIconBadge(
                padding: EdgeInsets.only(top:8),
                  child: GFIconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Cart()));
                    },
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.black,
                    size: GFSize.LARGE,
                  ),
                  counterChild:FutureBuilder(
                      future:getCart(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState !=
                            ConnectionState.waiting) {
                          return GFBadge(
                              shape: GFBadgeShape.circle,
                              child: Text(snapshot.data.length.toString()));
                        }else{
                          return Container();
                        }
                      }
                    ),
                ),
            ],
            expandedHeight:300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  Container(
                    height:80,
                    color: Colors.black,
                  ),
                  FutureBuilder(
                    future: getAds(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState != ConnectionState.waiting){
                        img = snapshot.data['urls'];
                        return (img!=null)?GFCarousel(
                          height: 210,
                          autoPlay: true,
                          viewportFraction: 1.0,
                          items: img.map(
                                (url) {
                              return Container(
                                color: Colors.black,
                                margin: EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15.0)),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ):Container(
                          child: GFCarousel(
                            height: 210,
                            autoPlay: true,
                            viewportFraction: 1.0,
                            items: imgBk.map(
                                  (url) {
                                return Container(
                                  color: Colors.black,
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        );
                      }else{
                        return Container(
                          child: GFCarousel(
                            height: 210,
                            autoPlay: true,
                            viewportFraction: 1.0,
                            items: imgBk.map(
                                  (url) {
                                return Container(
                                  color: Colors.black,
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        );
                      }
                    }
                  ),
                ],
              ),
            ),
          ),
        ];
        },
        body:Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:BorderRadius.only(
                topRight:Radius.circular(30),
                topLeft: Radius.circular(30)
            )
          ),
          child: ListView(
            children: [
              ListTile(
                title: Text("Category"),
                trailing: Text("view all"),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height:121,
                child: FutureBuilder(
                  future:getCat(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.waiting) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                height: 80,
                                width: 80,
                                child: ClipOval(
                                  child: Image.network(
                                      snapshot.data[index].data['url'],
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Container(
                                padding:EdgeInsets.only(top:5),
                                child:Text(snapshot.data[index].data['title']),
                              )
                            ],
                          );
                        },
                      );
                    }else{
                      return Container();
                    }
                  }
                ),
              ),
              ListTile(
                title: Text("New Arrival"),
                trailing: Text("view all"),
              ),
              Container(
                height:220,
                child: FutureBuilder(
                  future:getTop(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.waiting) {
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap:(){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProductDetails(snapshot:snapshot.data[index],)));
                              },
                              child: Container(
                                margin: EdgeInsets.all(8),
                                height: 220,
                                width: 150,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(15)),
                                  ),
                                  child: Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 100,
                                                child: Image(image: NetworkImage(snapshot.data[index].data['image']),
                                                    fit: BoxFit.cover),
                                              ),
                                              Container(
                                                height: 50,
                                                child: ListTile(
                                                  title: Text(snapshot.data[index]
                                                      .data['title']),
                                                  subtitle: Text(
                                                      snapshot.data[index].data['colors'][0]['price'].toString()),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            child: Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(50)),
                                              ),
                                              child: Icon(Icons.favorite,
                                                color: Colors.pink,),
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              ),
                            );
                          }
                      );
                    }else{
                      return Container();
                    }
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
