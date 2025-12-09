import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Namer app",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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

  void removeFavourite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
        page = PageGenerator();
      case 1:
        page = FavouritesPage();
      default:
        throw UnimplementedError('no widget in selected index $selectedIndex');
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraint) {
          if (constraint.maxWidth < 450) {
            return Column(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: page,
                    ),
                  ),
                ),
                SafeArea(
                  child: NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    indicatorColor: Colors.deepOrange,
                    destinations: [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: "Home",
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.favorite),
                        icon: Icon(Icons.favorite_outline),
                        label: "Favourite",
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraint.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text("Home"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text("Favourites"),
                      ),
                    ],
                    onDestinationSelected: (int index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    selectedIndex: selectedIndex,
                  ),
                ),
                Expanded(child: page),
              ],
            );
          }
        },
      ),
    );
  }
}

class PageGenerator extends StatelessWidget {
  const PageGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<MyAppState>();
    var pair = state.current;

    IconData icon;
    if (state.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  state.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text("Like"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  state.getNext();
                },
                child: Text("Click"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, appState, child) {
        return ListView(
          padding: EdgeInsets.all(10),
          children: [
            Text("Favourites", style: TextStyle().copyWith(fontSize: 30).copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            Center(child: Text("You have ${appState.favorites.length} favourites")),
            for (var favourite in appState.favorites)
              Card(
                child: ListTile(
                  title: Text(favourite.first),
                  subtitle: Text(favourite.second),
                  leading: Icon(Icons.favorite),
                  trailing: IconButton(onPressed: () {
                    appState.removeFavourite(favourite);
                  }, icon: Icon(Icons.delete)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Extract the app current theme

    // App font styling
    final fontStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: fontStyle,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
