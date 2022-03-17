import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../component/alert.dart';

class EditNotes extends StatefulWidget {
  final dynamic docId;
  final dynamic list;

  const EditNotes({
    Key? key,
    this.docId,
    this.list,
  }) : super(key: key);

  @override
  _EditNotesState createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  CollectionReference notesRef = FirebaseFirestore.instance.collection("notes");

  late Reference ref;
  late File? file;
  late String title, note, imageUrl;

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  editNotes(context) async {
    late FormState? formData = formState.currentState;

    if (file == null) {
      if (formData!.validate()) {
        showLoading(context);
        formData.save();
        await notesRef.doc(widget.docId).update({
          "title": title,
          "note": note,
        }).then((value) {
          Navigator.of(context).pushNamed(
            "homepage",
          );
        }).catchError((e) {
          print("$e");
        });
      }
    } else {
      if (formData!.validate()) {
        showLoading(context);
        formData.save();
        await ref.putFile(file!);
        imageUrl = await ref.getDownloadURL();
        await notesRef.doc(widget.docId).update({
          "title": title,
          "note": note,
          "imageUrl": imageUrl,
        }).then((value) {
          Navigator.of(context).pushNamed("homepage");
        }).catchError((e) {
          print("$e");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: Column(
        children: [
          Form(
            key: formState,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.list['title'],
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
                  initialValue: widget.list['note'],
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
                  //textColor: Colors.white,
                  child: const Text("Edit Image For Note"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await editNotes(context);
                  },
                  child: Text(
                    "Edit Note",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
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
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Image",
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
                        Icons.photo_outlined,
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(
                        "From Gallery",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  var picked =
                      await ImagePicker().getImage(source: ImageSource.camera);
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
