import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokeinfo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory dir = await getTemporaryDirectory();
  Hive.init(dir.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokeddex',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PokeList(),
    );
  }
}

class PokeList extends StatefulWidget {
  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  Future<List<String>> getPokemon() async {
    String filename = "pokelist.json";
    Directory dir = await getTemporaryDirectory();
    File file = File(dir.path + '/' + filename);

    Map response;

    if (file.existsSync()) {
      final data = file.readAsStringSync();
      response = json.decode(data);
    } else {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=898');
      http.Response request = await http.get(url);
      response = json.decode(request.body);

      file.writeAsStringSync(request.body, flush: true, mode: FileMode.write);
    }

    List<String> pokemonList = [];

    for (var pokemon in response['results']) {
      String pokemonName = pokemon['name'];

      pokemonList.add(pokemonName);
    }

    return pokemonList;
  }

  Widget appBarTitle = Text("Pokedex", style: TextStyle(color: Colors.black));
  Icon actionIcon = Icon(
    Icons.search,
    color: Colors.black,
  );

  Widget buildBar(BuildContext context, List<String> pokelist) {
    return new AppBar(backgroundColor: Colors.white, title: appBarTitle, actions: [
      IconButton(
          icon: this.actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = Icon(Icons.close, color: Colors.black);

                this.appBarTitle = TextField(
                  style: TextStyle(color: Colors.black),
                  onChanged: (text) {
                    text = text.toLowerCase();
                    setState(() {
                      filteredList.clear();
                      searching = true;
                      searchFilter(text, pokelist);
                      if (text == "") {
                        searching = false;
                      }
                    });
                  },
                );
              } else {
                this.actionIcon = Icon(
                  Icons.search,
                  color: Colors.black,
                );
                searching = false;
                this.appBarTitle = Text("Pokedex", style: TextStyle(color: Colors.black));
              }
            });
          })
    ]);
  }

  bool searching = false;
  List<String> filteredList = [];

  void searchFilter(String query, List<String> pokemon) {
    for (int i = 0; i < 898; i++) {
      if (pokemon[i].startsWith(query)) {
        filteredList.add(pokemon[i]);
      }
    }

    for (int i = 0; i < 898; i++) {
      if (pokemon[i].contains(query) && !filteredList.contains(pokemon[i])) {
        filteredList.add(pokemon[i]);
      }
    }
  }

  Widget mainList(int length, List maindata, List data) {
    return ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black12, width: 1), borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                  child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PokeInfo(data[index])));
                      },
                      child: ListTile(
                        title: Text(
                          '#${maindata.indexOf(data[index]) + 1} ${data[index]}',
                          textScaleFactor: 1.5,
                          style: TextStyle(color: Colors.black),
                        ),
                      ))));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: getPokemon(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Scaffold(
                  appBar: buildBar(context, snapshot.data),
                  body: snapshot.hasData
                      ? mainList(!searching ? snapshot.data.length : filteredList.length, snapshot.data,
                          !searching ? snapshot.data : filteredList)
                      : Center(child: CircularProgressIndicator()));
            }));
  }
}
