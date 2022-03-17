import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../component/alert.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String myPassword, myEmail;
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  signIn() async {
    var formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      try {
        showLoading(context);
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: myEmail,
          password: myPassword,
        );
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            title: "Error",
            body: const Text(
              "No user found for that email",
            ),
          ).show();
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            title: "Error",
            body: const Text(
              "Wrong password provided for that user",
            ),
          ).show();
        }
      }
    } else {
      print("Not Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset("images/logo.png")),
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formState,
              child: Column(
                children: [
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
                        prefixIcon: Icon(Icons.person),
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1))),
                  ),
                  const SizedBox(height: 20),
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
                      prefixIcon: Icon(Icons.person),
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
                          "if you haven't account ",
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacementNamed("signup");
                          },
                          child: const Text(
                            "Click Here",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //textColor: Colors.white,
                    onPressed: () async {
                      var user = await signIn();
                      if (user != null) {
                        Navigator.of(context).pushReplacementNamed("homepage");
                      }
                    },
                    child: Text(
                      "Sign in",
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
