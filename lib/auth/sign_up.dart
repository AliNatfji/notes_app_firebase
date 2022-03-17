import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../component/alert.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String myUserName, myPassword, myEmail;
  var fbm = FirebaseMessaging.instance;


  GlobalKey<FormState> formState = GlobalKey<FormState>();

  signUp() async {
    FormState? formData = formState.currentState;
    if (formData!.validate()) {
      print('valid');
      formData.save();
      try {
        showLoading(context);
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: myEmail,
          password: myPassword,
        );
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            title: "Error",
            body: const Text(
              "Password is to weak",
            ),
          ).show();
        }
        else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            title: "Error",
            body: const Text(
              "The account already exists for that email",
            ),
          ).show();
        }
      } catch (e) {
        print(e);
      }
    } else {
      print('Not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 100,
          ),
          Center(
            child: Image.asset(
              "images/logo.png",
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formState,
              child: Column(
                children: [
                  TextFormField(
                    onSaved: (val) {
                      myUserName = val!;
                    },
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return "username can't to be larger than 100 letter";
                      }
                      if (value != null && value.length < 2) {
                        return "username can't to be less than 2 letter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      hintText: "username",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onSaved: (val) {
                      myEmail = val!;
                    },
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return "Email can't to be larger than 100 letter";
                      }
                      if (value != null && value.length < 2) {
                        return "Email can't to be less than 2 letter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      hintText: "email",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onSaved: (val) {
                      myPassword = val!;
                    },
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return "Password can't to be larger than 100 letter";
                      }
                      if (value != null && value.length < 4) {
                        return "Password can't to be less than 4 letter";
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      hintText: "password",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Text(
                          "if you have Account ",
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              "login",
                            );
                          },
                          child: const Text(
                            "Click Here",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserCredential? response = await signUp();
                      print("===================");
                      if (response != null) {
                        fbm.getToken().then((token) async {
                          print("=================== Token ==================");
                          print(token);
                          await FirebaseFirestore.instance
                              .collection("users")
                              .add({
                            "username": myUserName,
                            "email": myEmail,
                            'password': myPassword,
                            'token': token,
                          });
                          print("====================================");
                        });
                        // await FirebaseFirestore.instance
                        //     .collection("users")
                        //     .add({
                        //   "username": myUserName,
                        //   "email": myEmail,
                        //   'password': myPassword,
                        //   '
                        // });
                        Navigator.of(context).pushReplacementNamed("homepage");
                      } else {
                        print("Sign Up Failed");
                      }
                      print("===================");
                    },
                    child: Text(
                      "Sign Up",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
