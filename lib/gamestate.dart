import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'player.dart';

/*
** Gamestate class
** Keeps track of all important data for the game. 
** Need to be able to save the gamestate after closing app
** need to move player list into the gamestate
*/
class GameState extends ChangeNotifier {
  var scoreSortType = 0;
  var sortTypes = ["default", "decending", "ascending"];
  var sortIcons = [
    Icons.sort_sharp,
    Icons.keyboard_double_arrow_up,
    Icons.keyboard_double_arrow_down
  ];
  var startingScore = 0;
  var players = <Player>[];
  var gameStart = false;

  GameState();

  // cycles the score sorting type
  void scoreSort() {
    scoreSortType += 1;
    if (scoreSortType >= sortTypes.length) {
      scoreSortType = 0;
    }
  }

  // returns the score sorting type
  String scoreType() {
    return sortTypes[scoreSortType];
  }

  // returns the icon associated with the sorting type
  IconData scoreTypeIcon() {
    return sortIcons[scoreSortType];
  }

  // adds a player to the player list
  void addPlayer(name) {
    players.add(Player(name, startingScore, players.length));
  }

  // removes a play form the player list
  void removePlayer(index) {}

  // Updates the starting score
  void updateBaseScore(var score) {
    startingScore = score;
  }

  // different sorting methods for displaying the players
  void sortPlayers() {
    switch (scoreType()) {
      // sorts by the lowest score first
      case "ascending":
        players.sort((a, b) => a.score.compareTo(b.score));
      // sorts by th highest score first
      case "decending":
        players.sort((a, b) => b.score.compareTo(a.score));
      // sorts by the players index (made when the player is added)
      default:
        players.sort((a, b) => a.index.compareTo(b.index));
    }
    notifyListeners();
  }

  void newGame() {
    clearScores();
    gameStart = true;
  }

  // clear scores will set all players scores to the default
  void clearScores(){
    for (var player in players) {
      player.score = startingScore;
    }
  }

  // a function for setting up the new game page
  // has the option to clear the players
  void clearGame(fullClear) {
    clearScores();
    gameStart = false;
    if (fullClear) {
      players.clear();
    }
    notifyListeners();
  }

  calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      // ignore: deprecated_member_use
      textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
    )..layout();
    return textPainter.size;
  }
}