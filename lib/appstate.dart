import 'package:flutter/material.dart';
import 'gamestate.dart';

class MyAppState extends ChangeNotifier {
  var gamestate = GameState();

  // adds a player to the game
  void addPlayer(String name) {
    gamestate.addPlayer(name);
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}