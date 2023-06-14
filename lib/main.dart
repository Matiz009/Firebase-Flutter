import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sp20_bse_042_terminal/signup.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  QuerySnapshot snapshot=await FirebaseFirestore.instance.collection('users').get();
  log(snapshot.docs.toString());
  for(var doc in snapshot.docs){
    log(doc.data().toString());
  }
  Map<String,dynamic> newUser={
    "name":"Ahmad",
    "email":"ahmad@gmail.com"
  };
  //await FirebaseFirestore.instance.collection('users').add(newUser);
  await FirebaseFirestore.instance.collection('users').doc('id-1').set(newUser);
  //For updating data
  await FirebaseFirestore.instance.collection('users').doc('id-1').update({
    "name":"Junaid",
    "email":"jd23@hotmail.com"
  });
  log('user updated');
  //For Deleting data
  //await FirebaseFirestore.instance.collection('users').doc('id-1').delete();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'APP',
      home: SignUpScreen(),
    );
  }
}


