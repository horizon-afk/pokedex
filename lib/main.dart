import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokeinfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokeddex',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue[700],
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Pokedex",
            style: TextStyle(color: Colors.black),
          )),
      body: PokeList(),
    );
  }
}

class PokeList extends StatefulWidget {
  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  Future<List<String>> getPokemon() async {
    List<String> pokemonList = [];
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=898');
    http.Response request = await http.get(url);
    Map response = json.decode(request.body);

    for (var pokemon in response['results']) {
      String pokemonName = pokemon['name'];

      pokemonList.add(pokemonName);
    }

    return pokemonList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: getPokemon(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white70, width: 1),
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                        child: ListTile(
                      title: Text(
                        '#${index + 1} ${snapshot.data[index]}',
                        textScaleFactor: 1.5,
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PokeInfo(snapshot.data[index])));
                      },
                    )));
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}
