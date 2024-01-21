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
  var players = <Player>[];
  var gamestate = Gamestate();

  // adds a player to the game
  void addPlayer(String name, int score) {
    gamestate.addPlayer();
    players.add(Player(name, score, gamestate.playerCount));
    notifyListeners();
  }


  // different sorting methods for displaying the players
  void sortPlayers() {
    switch (gamestate.scoreType())
    {
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
  void addScore(int points){
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
class Gamestate extends ChangeNotifier {
  var scoreSortType = 0;
  var sortTypes = ["default", "decending", "ascending"];
  var sortIcons = [Icons.sort_sharp, Icons.keyboard_double_arrow_up, Icons.keyboard_double_arrow_down];
  var playerCount = 0;
  var startingScore = 0;

  Gamestate();

  // cycles the score sorting type
  void scoreSort(){
    scoreSortType += 1;
    if (scoreSortType >= sortTypes.length){
      scoreSortType = 0;
    }
  }

  // returns the score sorting type
  String scoreType(){
    return sortTypes[scoreSortType];
  }

  // returns the icon associated with the sorting type
  IconData scoreTypeIcon(){
    return sortIcons[scoreSortType];
  }

  // adds a player to the player count
  void addPlayer(){
    playerCount++;
  }

  // removes a play form the player count
  void removePlayer(){
    playerCount--;
  }

  // Updates the starting score
  void updateBaseScore(var score){
    startingScore = score;
  }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = NewGamePage();
      case 1:
        page = ScorePage();
      case 2:
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
            icon: Icon(Icons.add_circle_rounded),
            label: 'New Game',
          ),
          NavigationDestination(
            icon: Icon(Icons.festival),
            label: 'Scores',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ]
      ),
      body: 
        Row(
          children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],)
    );
  }
}

// A temperary page for making a new game. Eventually needs to be merged with the score page
class NewGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var players = appState.players;
    var theme = Theme.of(context);

    // Texbox for naming a player
    var nameController = TextEditingController();


    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              for (var player in players)
                NameCardSmall(player: player),
            SizedBox(height: 10,),
            TextField(
              controller: nameController,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (players.length < 6){
                      appState.addPlayer(nameController.text, 0);
                    }
                    else{

                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text("New Player"),
                ),
                SizedBox(width:10),
                IconButton(
                  color: theme.primaryColor,
                  onPressed: () {
                  },
                  icon: Icon(Icons.play_arrow),
                ),
              ],
            ),
          ],
        ),
    );
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
    var players = appState.players;
    var theme = Theme.of(context);

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  // scaling for the score cards
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minWidth: MediaQuery.of(context).size.width * 0.85,
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                child: Column(children: [
              for (var player in players)
                NameCardFull(player: player, gamestate: appState.gamestate,),]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // A button for changing how the scores are sorted. The Icon is updated accordingly
                  IconButton(
                    icon: Icon(appState.gamestate.scoreTypeIcon()), 
                    color: theme.primaryColor,
                    onPressed: () {
                      appState.gamestate.scoreSort();
                      appState.sortPlayers();
                    },
                  ),
                  SizedBox(width:15),

                  // A button for adding score to each player
                  // For now just adds random score -- Need to add input from user
                  IconButton(
                    icon: Icon(Icons.add), 
                    color: theme.primaryColor,
                    onPressed: () {
                      var rng = Random();
                      for (var player in players){
                        player.addScore(rng.nextInt(10));
                      }                    
                      appState.sortPlayers();
                    },
                  ),
              ],
            )
          ],
        ),
    );
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
    var appState = context.watch<MyAppState>();

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
        ],
      ),
    );
  }
}


// A widget for displaying a players name and score
class NameCardFull extends StatelessWidget {
  const NameCardFull({
    super.key,
    required this.player,
    required this.gamestate,
    });

  final Player player;
  final Gamestate gamestate;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var style = theme.textTheme.displayMedium!.copyWith(
      // change the font size based on how many cards we have, making them smaller as we have more
      fontSize: gamestate.playerCount > 4 ? 40 : 50,
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // makes the size of the box smaller based on the number of players to fit them all in the space nicely
          maxHeight: gamestate.playerCount > 4 ? MediaQuery.of(context).size.height * 0.6 * .15 : MediaQuery.of(context).size.height * 0.6 * .2,
        ),
          child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 200,
                  maxWidth: 200,
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
                alignment: Alignment.topLeft,
                child: Text(
                  "${player.score}",
                  style: style
                )
              )
            ],
          ),
        )
      )
    );
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