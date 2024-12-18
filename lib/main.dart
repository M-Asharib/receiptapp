import 'package:flutter/material.dart';
import 'package:receipt_app/screen/login_screen.dart';
// import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyD3pXxWIJL5Ws0pt00uM5RrT1qQ2Ox4Fk4",
        authDomain: "receiptapp-2dcd4.firebaseapp.com",
        projectId: "receiptapp-2dcd4",
        storageBucket: "receiptapp-2dcd4.firebasestorage.app",
        messagingSenderId: "421564393425",
        appId: "1:421564393425:web:6829f355160285fb02e2f0",
        measurementId: "G-TEM6WS6E9D"
    ),
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
