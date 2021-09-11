// pokemon class to store data about tthe pokemon and show it effectively
class Pokemon {
  final int index;
  final String name;
  final String type;
  String description;
  final String image;
  final int height;
  final int weight;
  final List evolution;

  Pokemon({this.index, this.name, this.type, this.description, this.image, this.height, this.weight, this.evolution});
}
