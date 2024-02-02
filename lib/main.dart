import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
//import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          platform: TargetPlatform.android,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

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
    for (var player in players) {
      player.score = startingScore;
    }
    gameStart = true;
  }

  // a function for setting up the new game page
  // has the option to clear the players
  void clearGame(fullClear) {    
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ScorePage();
      case 1:
        page = SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // navigation menu for moving to different pages.
    // eventually needs to be condensed into 2 pages.
    return Scaffold(
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            selectedIndex: selectedIndex,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.festival),
                label: 'Scores',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ]),
        body: Row(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ));
  }
}

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
                            _scorePopupDialog(context, player),
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
                    gamestate.clearGame(false);
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
                              _newPlayerDialog(context));
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _warningPopupDialog(
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

/*
** Settings page
** A place to change things like player count, sort type, have rounds and winning scores
** still needs to be implemented
*/
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

// A pop up for adding points to each players score
Widget _scorePopupDialog(BuildContext context, Player player) {
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
                builder: (BuildContext context) =>
                    _warningPopupDialog(context, "Please Enter a Valid Number"),
              );
            }
          },
        ),
      ],
    ),
  );
}

// a widget to notify the use when there is an error
Widget _warningPopupDialog(BuildContext context, String message) {
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

Widget _newPlayerDialog(BuildContext context) {
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
                  builder: (BuildContext context) => _warningPopupDialog(
                      context, "Please Enter a Valid Name"));
            }
          },
        ),
      ],
    ),
  );
}

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
    var nameSize = gamestate.calcTextSize(player.name, style);
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
