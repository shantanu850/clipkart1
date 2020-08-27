import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Home.dart';

void main(){
  runApp(MyApp());
}
//main class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Loading(),
    );
  }
}

//loading class
class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}
class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.waiting){
            if (snapshot.data != null) {
              return Home();
            } else {
              return MyHomePage();
            }
          }else{
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Text("Loading...."),
              ),
            );
          }
        }
    );
  }
}

//login class
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  PageController _controller = new PageController(initialPage:0, viewportFraction: 1.0);
  String email,password,confpassword;
  bool loging;

  //form key to control form
  final formKey = new GlobalKey<FormState>();
  final formKeyReg = new GlobalKey<FormState>();
  final formKeyReset = new GlobalKey<FormState>();


  //scaffold key to control sackbar and scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> resetPassword(String email,context) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email:email).whenComplete(() => Navigator.of(context).pop());
  }
  //function to check user login state state
  checkUser(){

  }
  showReset(BuildContext context) {
    bool send = false;
    String email;
    AlertDialog alert = AlertDialog(
      title: Text("We will send you password reset link", maxLines: 1,),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Form(
          key: formKeyReset,
          child: TextFormField(
            obscureText: false,
            decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.person, color: Colors.redAccent),
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
              focusedBorder: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
              enabledBorder: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(
                    color: Colors.redAccent,
                  )),
            ),
            validator: (val) {
              Pattern pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(val)) {
                return 'Email format is invalid';
              } else {
                return null;
              }
            },
            onChanged: (value) {
              email = value; //get the value entered by user.
            },
            keyboardType: TextInputType.emailAddress,
            style: new TextStyle(
              height: 1.0,
              fontSize: 14,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ),
      actions: [
        (send == false) ? ButtonBar(
            children: [
              FlatButton(
                onPressed: () {
                  if (formKeyReset.currentState.validate()) {
                    resetPassword(email, context);
                    setState(() {
                      send = true;
                    });
                  }
                }, child: Text("Send"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              )
            ]
        ) : FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Done"),
        )
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  void initState() {
    super.initState();
    loging = false;
  }

  //sign in function
  signInEmail(String email,String password,context) async{
    try {
      AuthResult authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email:email,password:password);
      if (authResult.user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Home()));
        //navigate to home
      } else {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Unexpected error'),
              duration: Duration(seconds: 3),
            ));
      }
    }catch(e){
      print('Exception @createAccount: $e');
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: Duration(seconds: 3),
          ));
      setState(() {
        loging = false;
      });
    }
  }

  //signUp function
  signUpEmail(email, password,context) async{
    try {
      AuthResult authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email:email,password:password);
      if(authResult.user != null){
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        Firestore.instance.collection('user').document(user.uid).setData({
          'uid':user.uid,
          'email':email,
        });
        authResult.user.sendEmailVerification();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Home()));
        //navigate to home
      }else{
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Unexpected error'),
              duration: Duration(seconds: 3),
            ));
      }
    }catch(e){
      print('Exception @createAccount: $e');
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: Duration(seconds: 3),
          ));
      setState(() {
        loging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/party.jpg'),fit:BoxFit.cover)
        ),
        child: Container(
          padding: EdgeInsets.only(top:84),
          color: Colors.blue.withOpacity(0.5),
          child: Center(
              child: PageView(
                controller: _controller,
                children: [
                  login(),
                  register(),
                ],
              )
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Widget login(){
    return Container(
      child: Center(
        child: Form(
          key:formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:30.0),
                child: ListTile(
                  title: Text("Welcome Back !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize:36,
                        color: Colors.white),
                  ),
                  subtitle:Text("Login to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal:40),
                child: Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        obscureText: false,
                        decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.person,
                              color: Colors.white),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white12,
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.transparent,
                              )),
                          enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white38,
                              )),
                        ),
                        validator: (val) {
                          Pattern pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(val)) {
                            return 'Email format is invalid';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          email = value; //get the value entered by user.
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          height: 1.0,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.lock,color: Colors.white),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white12,
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white,
                              )),
                          enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white38,
                              )),
                        ),
                        validator: (val) {
                          if(val.length<8){
                            return 'Password cant be less than 8';
                          }else{
                            return null;
                          }
                        },
                        onChanged: (value) {
                          password = value; //get the value entered by user.
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          height: 1.0,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        showReset(context);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top:20,right:15),
                          child: Text("Forgot Password ?"
                            ,style: TextStyle(color: Colors.white),textAlign: TextAlign.right,
                          )),
                    ),
                    GestureDetector(
                      onTap:(){
                        if(formKey.currentState.validate()){
                          loging = true;
                          signInEmail(email, password,context);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top:20),
                        alignment: Alignment.center,
                        height:50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child:(loging==false)?Text("Sign In",style:TextStyle(color:Colors.white),):Text("Please wait"),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _controller.animateToPage(
                          1,
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeInOutExpo,
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.only(top:20),
                          child: Text("Don't have an account ? Sign Up"
                            ,style: TextStyle(color: Colors.white),textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget register(){
    return Container(
      child: Center(
        child: Form(
          key:formKeyReg,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:30.0),
                child: ListTile(
                  title: Text("New Here ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize:36,
                        color: Colors.white),
                  ),
                  subtitle:Text("Create a account to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal:40),
                child: Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        obscureText: false,
                        decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.person,
                              color: Colors.white),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white12,
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.transparent,
                              )),
                          enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white38,
                              )),
                        ),
                        validator: (val) {
                          Pattern pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(val)) {
                            return 'Email format is invalid';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          email = value; //get the value entered by user.
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          height: 1.0,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.lock,
                              color: Colors.white),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white12,
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white,
                              )),
                          enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white38,
                              )),
                        ),
                        validator: (val) {
                          if (val.length<8) {
                            return 'Password cant be less than 8';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          password = value; //get the value entered by user.
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          height: 1.0,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: new InputDecoration(
                          prefixIcon: new Icon(Icons.lock,
                              color: Colors.white),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white12,
                          filled: true,
                          border: new OutlineInputBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white,
                              )),
                          enabledBorder: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                                color: Colors.white38,
                              )),
                        ),
                        validator: (val) {
                          if (val.length<8) {
                            return 'Password cant be less than 8';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          confpassword = value; //get the value entered by user.
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          height: 1.0,
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        if(confpassword==password) {
                          if (formKeyReg.currentState.validate()) {
                            loging = true;
                            signUpEmail(email, password,context);
                          }
                        }else{
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text('Password and Confirm password not matched'),
                                duration: Duration(seconds: 3),
                              ));
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top:20),
                        alignment: Alignment.center,
                        height:50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child:(loging==false)?Text("Sign Up",style: TextStyle(color:Colors.white),):Text("Please wait"),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _controller.animateToPage(
                          0,
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeInOutExpo,
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.only(top:20),
                          child: Text("Already have an account ? Sign In"
                            ,style: TextStyle(color: Colors.white),textAlign: TextAlign.center,
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}