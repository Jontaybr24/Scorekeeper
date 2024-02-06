import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'appstate.dart';
import 'namecard.dart';
import 'popups.dart';

/*
** The Main page of the app once a game has been started
** Keeps score for all the players in the game
*/
class ScorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var gamestate = appState.gamestate;
    var players = gamestate.players;
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    return Center(
        child: SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              // scaling for the score cards
              minHeight: size.height * 0.6,
              maxHeight: size.height * 0.6,
              minWidth: size.width * 0.85,
              maxWidth: size.width * 0.85,
            ),
            child: GridView.count(
                crossAxisCount: gamestate.players.length <= 6 ? 1 : 2,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: gamestate.players.length <= 4
                    ? ((size.width * 0.75) / (size.height * 0.6 * .2))
                    : gamestate.players.length <= 6
                        ? ((size.width * 0.85) / (size.height * 0.6 * .15))
                        : ((size.width * 0.42) / (size.height * 0.6 * .15)),
                children: [
                  for (var player in players)
                    NameCardFull(
                      player: player,
                      gamestate: appState.gamestate,
                    ),
                ]),
          ),
          // This row will only be shown during a game
          // It contains a score sort button, an add scores button and a reset game button
          if (gamestate.gameStart)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // A button for changing how the scores are sorted. The Icon is updated accordingly
                IconButton(
                  icon: Icon(appState.gamestate.scoreTypeIcon()),
                  color: theme.primaryColor,
                  onPressed: () {
                    gamestate.scoreSort();
                    gamestate.sortPlayers();
                    appState.update();
                  },
                ),
                SizedBox(width: 15),

                // A button for adding score to each player
                IconButton(
                  icon: Icon(Icons.add),
                  color: theme.primaryColor,
                  onPressed: () {
                    for (var player in players) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            scorePopupDialog(context, player),
                      );
                    }
                    gamestate.sortPlayers();
                    appState.update();
                  },
                ),
                SizedBox(width: 15),
                // A button for adding score to each player
                IconButton(
                  icon: Icon(Icons.restart_alt_rounded),
                  color: theme.primaryColor,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            resetDialog(context));
                    appState.update();
                  },
                ),
              ],
            )
          // This row will only be shown before a game is started
          // It contains a new player button and a start game button
          else if (!gamestate.gameStart)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (players.length < 12) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              newPlayerDialog(context));
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              warningPopupDialog(
                                  context, "Player Limit Reached"));
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text("New Player"),
                ),
                SizedBox(width: 10),
                IconButton(
                  color: theme.primaryColor,
                  onPressed: () {
                    gamestate.newGame();
                    appState.update();
                  },
                  icon: Icon(Icons.play_arrow),
                ),
              ],
            ),
        ],
      ),
    ));
  }
}