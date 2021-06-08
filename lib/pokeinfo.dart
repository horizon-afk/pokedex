import 'package:flutter/material.dart';

class PokeInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pokeddex',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Info());
  }
}

class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
