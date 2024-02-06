import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appstate.dart';
import 'player.dart';


  // A pop up for adding points to each players score
  Widget scorePopupDialog(BuildContext context, Player player) {
    var scoreInput = TextEditingController();
    var appState = context.watch<MyAppState>();

    return AlertDialog(
      title: Text(
        player.name,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: scoreInput,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: () {
              try {
                player.addScore(int.parse(scoreInput.text));
                appState.gamestate.sortPlayers();
                appState.update();
                Navigator.of(context).pop();
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => warningPopupDialog(
                      context, "Please Enter a Valid Number"),
                );
              }
            },
          ),
        ],
      ),
    );
  }

// a widget to notify the use when there is an error
  Widget warningPopupDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text(
        "Error",
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Widget newPlayerDialog(BuildContext context) {
    var nameController = TextEditingController();
    var appState = context.watch<MyAppState>();

    return AlertDialog(
      title: Text(
        "New Player",
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: nameController,
            keyboardType: TextInputType.name,
            autofocus: true,
            textAlign: TextAlign.center,
            //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onEditingComplete: () {
              if (nameController.text != "") {
                appState.addPlayer(nameController.text);
                appState.update();
                Navigator.of(context).pop();
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => warningPopupDialog(
                        context, "Please Enter a Valid Name"));
              }
            },
          ),
        ],
      ),
    );
  }

// Dialog for resettiing the game
  Widget resetDialog(BuildContext context) {
    //var nameController = TextEditingController();
    var appState = context.watch<MyAppState>();

    return AlertDialog(
        title: Text(
          "Reset the game?",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[],
        ),
        actions: <Widget>[
          BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
              onPressed: () {
                appState.gamestate.clearGame(true);
                Navigator.of(context).pop();
                appState.update();
              },
              child: Text("Clear Players")),
          TextButton(
              onPressed: () {
                appState.gamestate.clearGame(false);
                Navigator.of(context).pop();
                appState.update();
              },
              child: Text("New Game"))
        ]);
  }
