import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon.dart';
import 'arrow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PokeInfo extends StatelessWidget {
  final String pokemonName;
  PokeInfo(this.pokemonName);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Pokeddex', theme: ThemeData(primarySwatch: Colors.blue), home: Info(pokemonName));
  }
}

class Info extends StatelessWidget {
  final String pokemonName;
  Info(this.pokemonName);

  void initHive() async {}

  Future<Pokemon> getPokeInfo() async {
    // initialized box tto store data in json format
    Box box = await Hive.openBox("data");

    Map pokemon;
    Map species;
    Map evolution;

    Map data = box.get(pokemonName);

    if (data != null) {
      pokemon = data['pokemon'];
      species = data['species'];
      evolution = data['evolution'];
    } else {

      //gettingg the file directly from the API
      final url = "https://pokeapi.co/api/v2/";

      final pokemonUrl = Uri.parse('$url/pokemon/$pokemonName');
      http.Response pokemonRequest = await http.get(pokemonUrl);
      pokemon = json.decode(pokemonRequest.body);

      final speciesUrl = Uri.parse("$url/pokemon-species/${pokemon['id']}");
      http.Response speciesRequest = await http.get(speciesUrl);
      species = json.decode(speciesRequest.body);

      String evolutionChain = species['evolution_chain']['url'];

      final evolutionUrl = Uri.parse(evolutionChain);
      http.Response evolutionRequest = await http.get(evolutionUrl);
      evolution = json.decode(evolutionRequest.body);
      
      // storing the data from the API in the box for caching
      Map data = {'pokemon': pokemon, 'species': species, 'evolution': evolution};

      box.put(pokemonName, data);
    }

    String description() {
      String description;
      for (int i = 0; i < species['flavor_text_entries'].length; i++) {
        if (species['flavor_text_entries'][i]['language']['name'] == "en") {
          description = species['flavor_text_entries'][i]['flavor_text'];
          break;
        }
      }
      return description;
    }

    List evolutionList() {
      List evolutionList = [];
      // this statement removes all characters except numbers from a string
      int intValue = int.parse(evolution['chain']['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));

      Pokemon first = Pokemon(
          index: intValue,
          name: evolution['chain']['species']['name'],
          image:
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

      List second = evolution['chain']['evolves_to'];

      if (second.length != 0) {
        List third = evolution['chain']['evolves_to'][0]['evolves_to'];

        // forr multiple evolutions
        if (second.length > 1) {
          for (int i = 0; i < second.length; i++) {
            intValue = int.parse(second[i]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));

            Pokemon evolved = Pokemon(
                index: intValue,
                name: second[i]['species']['name'],
                image:
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

            List branch = [first, evolved];

            if (second[i]['evolves_to'].length != 0) {
              third = second[i]['evolves_to'];
              intValue = int.parse(third[0]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));

              Pokemon thirdPokemon = Pokemon(
                  index: intValue,
                  name: third[0]['species']['name'],
                  image:
                      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

              branch.add(thirdPokemon);
            }
            evolutionList.add(branch);
          }
        } else {
          
          // for pokemons havving multiple evolutions after the first evoltuion
          if (second[0]['evolves_to'].length > 1) {
            for (int i = 0; i < second[0]['evolves_to'].length; i++) {
              intValue = int.parse(second[0]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));
              Pokemon secondPokemon = Pokemon(
                  index: intValue,
                  name: second[0]['species']['name'],
                  image:
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

              third = second[0]['evolves_to'];

              intValue = int.parse(third[i]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));

              Pokemon thirdPokemon = Pokemon(
                  index: intValue,
                  name: third[i]['species']['name'],
                  image:
                      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

              evolutionList.add([first, secondPokemon, thirdPokemon]);
            }
          } else {

            // for single evolution 
            intValue = int.parse(second[0]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));

            Pokemon evolved = Pokemon(
                index: intValue,
                name: second[0]['species']['name'],
                image:
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

            evolutionList.add(first);
            evolutionList.add(evolved);

            if (third.length != 0) {
              intValue = int.parse(third[0]['species']['url'].substring(42).replaceAll(RegExp('[^0-9]'), ''));
              Pokemon evolved = Pokemon(
                  index: intValue,
                  name: third[0]['species']['name'],
                  image:
                      "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$intValue.png");

              evolutionList.add(evolved);
            }
          }
        }
      } else {
        evolutionList.add(first);
      }

      return evolutionList;
    }
    // capitalizing the first character of the name
    String name = "${pokemonName[0].toUpperCase()}${pokemonName.substring(1)}";

    return Pokemon(
        index: species['id'],
        name: name,
        type: pokemon['types'][0]['type']['name'],
        description: description(),
        image: pokemon['sprites']['other']['official-artwork']['front_default'],
        weight: pokemon['weight'],
        height: pokemon['height'],
        evolution: evolutionList());
  }

  @override
  Widget build(BuildContext context) {

    // gets the screen height and width
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    //shows basic stats of the pokemon like height, weight, type
    Widget basicStats(int height, int weight, String type) {
      return Container(
        width: screenWidth * 0.85,
        margin: EdgeInsets.only(top: screenHeight * 0.05, bottom: screenHeight * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [Text("Height", textScaleFactor: 1.8), Text("${height / 10} m", textScaleFactor: 1.4)],
            ),
            Column(
              children: [Text("Weight", textScaleFactor: 1.8), Text("${weight / 10} kg", textScaleFactor: 1.4)],
            ),
            Column(
              children: [
                Text("Type", textScaleFactor: 1.8),
                Text("${type[0].toUpperCase() + type.substring(1)}", textScaleFactor: 1.4)
              ],
            )
          ],
        ),
      );
    }
    // returns the pokemon image as a svg file or png file
    Widget pokemonImage(int id, String url) {
      if (id < 650) {
        return SvgPicture.asset('assets/$id.svg');
      } else {
        return Image(image: CachedNetworkImageProvider(url));
      }
    }

    //caches the svg files for faster loading
    Future<void> cacheSvgPicture(String image) async {
      await precachePicture(ExactAssetPicture(SvgPicture.svgStringDecoder, image), context);
    }

    // draws an arrrow off a certain length
    Widget arrow(double length) {
      return Container(
        height: 15,
        width: length,
        child: CustomPaint(
          painter: ArrowPainter(length),
        ),
      );
    }

    ///shows the evolution flow of the pokemon. Supports multiple evolution and no evolution and tapping on the pokemon
    Widget evolution(List evolution) {
      int length = evolution.length;
      int pos = 1;

      List<Widget> evolutionBtns = [];

      Widget evolutionFlow;

      try {
        if (evolution[0].length > 1 || evolution[0].length > 1) {
          for (int i = 0; i < length; i++) {
            pos = 1;
            List<Widget> singleEvolution = [];

            for (int j = 0; j < evolution[i].length; j++) {
              if (pos % 2 != 0) {
                pos++;
                singleEvolution.add(Container(
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => PokeInfo(evolution[i][j].name)));
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Column(
                          children: [
                            Container(
                                height: 100,
                                width: 100,
                                child: pokemonImage(evolution[i][j].index, evolution[i][j].image)),
                            Text(
                              "${evolution[i][j].name[0].toUpperCase()}${evolution[i][j].name.substring(1)}",
                              textScaleFactor: 1.5,
                            )
                          ],
                        ))));
              } else {
                pos++;
                singleEvolution.add(arrow(screenWidth / (evolution[0].length * evolution[0].length)));
                j--;
              }
            }
            evolutionBtns.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: singleEvolution));
          }
        }

        evolutionFlow = Column(children: evolutionBtns);

        return evolutionFlow;

      // when no multiple evolution is found, an exception is thrown which indicates single evolution flow
      } on NoSuchMethodError {
        for (int i = 0; i < length; i++) {
          if (pos % 2 != 0) {
            Widget evolutionBtn = Container(
                child: InkWell(
                    onTap: () {
                      // if a pokemon doesn't support evoultion,the length is 1 and tapping will have no function
                      if (length > 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PokeInfo(evolution[i].name)));
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      children: [
                        Container(height: 100, width: 100, child: pokemonImage(evolution[i].index, evolution[i].image)),
                        Text(
                          "${evolution[i].name[0].toUpperCase()}${evolution[i].name.substring(1)}",
                          textScaleFactor: 1.5,
                        )
                      ],
                    )));

            evolutionBtns.add(evolutionBtn);
          } else {
            evolutionBtns.add(arrow(screenWidth / (evolution.length * evolution.length)));
            i--;
          }

          pos++;
        }

        evolutionFlow = Container(
          child: Row(
            mainAxisAlignment: (evolution.length > 1) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: evolutionBtns,
          ),
        );
      }
      return evolutionFlow;
    }

    // the main screen
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.08, horizontal: screenWidth * 0.03),
          child: FutureBuilder(
              future: getPokeInfo(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  Pokemon pokemon = snapshot.data;

                  if (pokemon.index < 650) {
                    cacheSvgPicture('assets/${pokemon.index}.svg');
                  }

                  // formats the description of the pokemon in a better readable format
                  List<String> description = pokemon.description.split("");
                  for (int i = 0; i < pokemon.description.length; i++) {
                    if (pokemon.description[i] == "\n" || pokemon.description[i] == "") {
                      description[i] = " ";
                    }
                  }
                  pokemon.description = description.join();

                  return Container(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                    // pokemon image with name and index
                    Container(
                        height: screenHeight * 0.150,
                        width: screenHeight * 0.150,
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: pokemonImage(pokemon.index, pokemon.image)),
                    Text(
                      "#${pokemon.index} ${pokemon.name}",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                    ),

                    // basic stats
                    Align(child: basicStats(pokemon.height, pokemon.weight, pokemon.type)),

                    // pokemon description
                    Container(
                        child: Text(
                      "${pokemon.description}",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.5,
                    )),

                    // divider line which divides the description from evolution
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: Colors.black,
                          thickness: 2,
                          indent: screenWidth * 0.08,
                          endIndent: screenWidth * 0.08,
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          "EVOLUTION",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.5,
                        )),

                    // pokemon evolution flow
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: evolution(pokemon.evolution),
                    )
                  ]));

                  // circular progress indicator when data is loading
                } else {
                  return Container(height: screenHeight * 0.84, child: Center(child: CircularProgressIndicator()));
                }
              })),
    ));
  }
}
