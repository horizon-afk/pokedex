import 'package:flutter/material.dart';

class Pokemon {
  final int index;
  final String name;
  final String type;
  final String description;
  final Image image;
  final int height;
  final int weight;

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
