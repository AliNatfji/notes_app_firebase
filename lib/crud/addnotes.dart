import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../component/alert.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({Key? key}) : super(key: key);

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  CollectionReference notesRef = FirebaseFirestore.instance.collection("notes");

  late Reference ref;
  File? file;
  late String title, note, imageUrl;
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  addNotes(context) async {
    if (file == null) {
      return AwesomeDialog(
        context: context,
        title: "هام",
        body: const Text("please choose Image"),
        dialogType: DialogType.ERROR,
      )..show();
    }
    late FormState? formData = formState.currentState;
    if (formData!.validate()) {
      showLoading(context);
      formData.save();
      await ref.putFile(file!);
      imageUrl = await ref.getDownloadURL();
      await notesRef.add({
        "title": title,
        "note": note,
        "imageUrl": imageUrl,
        "userid": FirebaseAuth.instance.currentUser?.uid
      }).then((value) {
        Navigator.of(context).pushNamed("homepage");
      }).catchError((e) {
        print("$e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Note',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: formState,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value != null && value.length > 30) {
                        return "Title can't to be larger than 30 letter";
                      }
                      if (value != null && value.length < 2) {
                        return "Title can't to be less than 2 letter";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      title = val!;
                    },
                    maxLength: 30,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Title Note",
                      prefixIcon: Icon(
                        Icons.note,
                      ),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null && value.length > 255) {
                        return "Notes can't to be larger than 255 letter";
                      }
                      if (value != null && value.length < 10) {
                        return "Notes can't to be less than 10 letter";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      note = val!;
                    },
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Note",
                      prefixIcon: Icon(
                        Icons.note,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showBottomSheet(context);
                    },
                    child: const Text("Add Image For Note"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await addNotes(context);
                    },
                    child: Text(
                      "Add Note",
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

  showBottomSheet(context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please Choose Image",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () async {
                  var picked =
                      await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    file = File(picked.path);
                    var rand = Random().nextInt(100000);
                    var imageName = "$rand" + basename(picked.path);
                    ref = FirebaseStorage.instance.ref("images").child(imageName);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.photo_outlined,
                          size: 30,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "From Gallery",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),),
              ),
              InkWell(
                onTap: () async {
                  var picked =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    file = File(picked.path);
                    var rand = Random().nextInt(100000);
                    var imageName = "$rand" + basename(picked.path);
                    ref =
                        FirebaseStorage.instance.ref("images").child(imageName);
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.camera,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "From Camera",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
