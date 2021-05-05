import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokeddex',
      theme: ThemeData(
          primarySwatch: Colors.red, scaffoldBackgroundColor: Colors.red),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pokedex")),
      body: PokeList(),
    );
  }
}

class PokeList extends StatefulWidget {
  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  List<String> pokemonList = [];

  void getPokemon() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=898');
    http.Response request = await http.get(url);
    dynamic response = jsonDecode(request.body);

    const pokemons = 898;

    for (int i = 0; i < pokemons; i++) {
      String pokemon = response['results'][i]['name'];
      pokemonList.add(pokemon);
    }
  }

  @override
  Widget build(BuildContext context) {
    getPokemon();
    return Container(
        child: ListView.builder(
      itemCount: 898,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
          '#${index + 1}  ${pokemonList[index]}',
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.white),
        ));
      },
    ));
  }
}
