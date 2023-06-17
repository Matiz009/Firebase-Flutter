import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sp20_bse_042_terminal/loginscreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? profilePic;

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void addUsers() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    int age = int.parse(ageController.text.trim());

    try {
      nameController.clear();
      emailController.clear();
      ageController.clear();
      if (name != '' && email != '' && age>0 && profilePic!=null) {
        Random random = Random();
        int randomNumber = random.nextInt(1000);
        int randomNumber1 = random.nextInt(10000);
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('profiles').child('pic$randomNumber$randomNumber1').putFile(profilePic!);
        TaskSnapshot taskSnapshot=await uploadTask;
        String imageUrl=await taskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').add({
          "name": name,
          "email": email,
          "age":age,
          "profilePic":imageUrl
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record Added')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid action')));
      }
      setState(() {
        profilePic=null;
      });
    } catch (error) {
      print(error.toString());
    }
  }

  void delUser(String id) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have successfully deleted your data')));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              CupertinoButton(
                onPressed: ()async{
                  XFile? selectedImage=await ImagePicker().pickImage(source: ImageSource.gallery);
                  if(selectedImage!=null){
                    File cFile=File(selectedImage.path);
                    setState(() {
                      profilePic=cFile;
                    });
                    print("Image selected");
                  }else{
                    print("No image selected");
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: (profilePic != null) ? FileImage(profilePic!) : null,
                  radius: 50,
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  hintText: "Age",
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  addUsers();
                },
                child: const Text('Save Data'),
              ),
              const SizedBox(height: 4),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').where("age",whereNotIn: [22,34,35]).orderBy("age",descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userMap = snapshot.data!.docs[index].data();
                          return ListTile(
                            title: Text(userMap["name"]),
                            subtitle: Text("Age ${userMap["age"]}"),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userMap["profilePic"]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                delUser(snapshot.data!.docs[index].id);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
