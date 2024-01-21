import 'package:english_words/english_words.dart';
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          platform: TargetPlatform.iOS,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  var players = <Player>[];
  var gamestate = Gamestate();


  void addPlayer(String name, int score) {
    gamestate.addPlayer();
    players.add(Player(name, score, gamestate.playerCount));
    notifyListeners();
  }

  void sortPlayers() {
    switch (gamestate.scoreType())
    {
      case "ascending":
        players.sort((a, b) => a.score.compareTo(b.score));
        break;
      case "decending":
        players.sort((a, b) => b.score.compareTo(a.score));
        break;
      default:
        players.sort((a, b) => a.index.compareTo(b.index));
    }
    notifyListeners();
  }
}

class Player extends ChangeNotifier {
  var name = "";
  var score = 0;
  var index = 0;

  Player(this.name, this.score, this.index);

  void changeName(String newName) {
    name = newName;
  }

  void addScore(int points){
    score += points;
    notifyListeners();
  }

}

class Gamestate extends ChangeNotifier {
  var scoreSortType = 0;
  var sortTypes = ["default", "ascending", "decending"];
  var playerCount = 0;
  var startingScore = 0;

  Gamestate();

  void scoreSort(){
    scoreSortType += 1;
    if (scoreSortType >= sortTypes.length){
      scoreSortType = 0;
    }
  }

  String scoreType(){
    return sortTypes[scoreSortType];
  }

  void addPlayer(){
    playerCount++;
  }

  void removePlayer(){
    playerCount--;
  }

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
        break;
      case 1:
        page = ScorePage();
        break;
      case 2:
        page = FavoritesPage();
        break;
      case 3:
        page = SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }


    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_rounded),
                  label: Text('New Game'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.festival),
                  label: Text('Scores'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Likes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;                  
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class NewGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var players = appState.players;

    if(appState.favorites.contains(pair)){
    } else{
    }

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
                    if (players.length < 4){
                      appState.addPlayer(nameController.text, 0);
                    }
                    else{

                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text("New Player"),
                ),
                SizedBox(width:10),
                ElevatedButton.icon(
                  onPressed: () {
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text(''),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class ScorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var players = appState.players;

    if(appState.favorites.contains(pair)){
    } else{
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              for (var player in players)
                NameCardFull(player: player),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow), 
                  onPressed: () {
                    appState.gamestate.scoreSort();
                    appState.sortPlayers();
                  },
                  label: Text(''),
                ),
                SizedBox(width:10),
                ElevatedButton.icon(
                  icon: Icon(Icons.add), 
                  onPressed: () {
                    var rng = Random();
                    for (var player in players){
                      player.addScore(rng.nextInt(10));
                    }                    
                    appState.sortPlayers();
                  },
                  label: Text(''),
                ) 
              ],
            )
          ],
        ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if(appState.favorites.contains(pair)){
      icon = Icons.favorite;
    } else{
      icon = Icons.favorite_border;
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text(""),
                ),
                SizedBox(width:10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var pairs = appState.favorites;

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
        children: [
          Padding(padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
          ),
          for (var fav in pairs)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(fav.asPascalCase),
              onLongPress: () {
                //Vibration.vibrate();
                appState.removeFavorite(fav);
              },
              ),
        ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asPascalCase, 
          style: style,
          semanticsLabel: pair.asPascalCase,
          ),
      ),
    );
  }
}


class NameCardFull extends StatelessWidget {
  const NameCardFull({
    super.key,
    required this.player,
    });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
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
              child: Container(
                child: Text(
                  "${player.score}",
                  style: style
                )
              )
            )
          ],
        ),
      )
    );
  }
}


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