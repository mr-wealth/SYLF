import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/screens/welcome_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SYLF - See Your Line Follower',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}