import 'package:flutter/material.dart';
import 'player.dart';
import 'gamestate.dart';

// A widget for displaying a players name and score
class NameCardFull extends StatelessWidget {
  const NameCardFull({
    super.key,
    required this.player,
    required this.gamestate,
  });

  final Player player;
  final GameState gamestate;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    var style = theme.textTheme.displayMedium!.copyWith(
      // change the font size based on how many cards we have, making them smaller as we have more
      fontSize: gamestate.players.length <= 4
          ? 50
          : gamestate.players.length <= 6
              ? 35
              : 19,
      color: theme.colorScheme.onPrimary,
    );
    //var nameSize = gamestate.calcTextSize(player.name, style);
    //player.score = nameSize.width.toInt();

    return Card(
        color: theme.colorScheme.primary,
        child: ConstrainedBox(
            constraints: BoxConstraints(
              // makes the size of the box smaller based on the number of players to fit them all in the space nicely
              maxHeight: gamestate.players.length > 4
                  ? size.height * 0.6 * .15
                  : size.height * 0.6 * .2,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: gamestate.players.length <= 6 ? 180 : 60,
                    ),
                    child: Text(
                      player.name,
                      style: style,
                      semanticsLabel: player.name,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text("${player.score}", style: style))
                ],
              ),
            )));
  }
}

// A smaller version of the above. Still need to make adjustments so we can display cards side by side
class NameCardSmall extends StatelessWidget {
  const NameCardSmall({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          player.name,
          style: style,
          semanticsLabel: player.name,
        ),
      ),
    );
  }
}
