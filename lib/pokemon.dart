import 'package:flutter/material.dart';

class Pokemon {
  int index;
  String name;
  String type;
  String description;
  Image image;
  int height;
  int weight;

  Pokemon({
    this.index,
    this.name,
    this.type,
    this.description,
    this.image,
    this.height,
    this.weight,
  });
}
