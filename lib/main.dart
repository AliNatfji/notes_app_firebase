import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'auth/sign_up.dart';
import 'crud/addnotes.dart';
import 'home/homepage.dart';


 late bool isLogin ;

 Future backgroundMessage(RemoteMessage message) async {
    print("=================== BackGround Message ========================") ;
    print("${message.notification?.body}") ;
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessage) ;

  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    isLogin = false;
  } else {
    isLogin = true;
  }

  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLogin == false ? const Login() : const HomePage(),
      theme: ThemeData(
          fontFamily: "NotoSerif",
          backgroundColor: Colors.white,
          textTheme: const TextTheme(
            headline6: TextStyle(fontSize: 20, color: Colors.white),
            headline5: TextStyle(fontSize: 30, color: Colors.blue),
            bodyText2: TextStyle(fontSize: 20, color: Colors.black),
          ),),
      routes: {
        "login": (context) => const Login(),
        "signup": (context) => const SignUp(),
        "homepage": (context) => const HomePage(),
        "addnotes": (context) => const AddNotes(),
      },
    );
  }
}
