import 'package:flutter/material.dart';
import 'package:whatsapp/login.dart';
import 'package:whatsapp/routeGenerator.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

ThemeData tema = ThemeData();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();

  runApp(MaterialApp(
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      home: Login(),
      theme: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
              primary: Color(0xff075E54), secondary: Color(0xff25D366)))));
}



