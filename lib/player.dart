import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

/* 
** Player Class
** Keeps track of name and score
** eventually want to add customizable settings for each player, like card colors
*/
class Player extends ChangeNotifier {
  var name = "";
  var score = 0;
  var index = 0;

  Player(this.name, this.score, this.index);

  // changes the name of the player
  void changeName(String newName) {
    name = newName;
  }

  // adds to the players score
  void addScore(int points) {
    score += points;
    notifyListeners();
  }
}