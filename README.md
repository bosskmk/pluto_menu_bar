## PlutoMenuBar for flutter - v0.1.0

PlutoMenuBar is a horizontal menu bar for flutter.

### Features
- Multiple sub-menu : Add as many submenus as you like.

### Demo
[Demo Web](https://bosskmk.github.io/pluto_menu_bar/build/web/index.html)

### Installation
[pub.dev](https://pub.dev/packages/pluto_menu_bar)

### Screenshots

![PlutoMenuBar Image](https://bosskmk.github.io/images/pluto_menu_bar_img1.gif)

### Usage
```dart
import 'package:flutter/material.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('PlutoMenuBar'),
        ),
        body: PlutoMenuBarDemo(scaffoldKey: _scaffoldKey),
      ),
    );
  }
}

class PlutoMenuBarDemo extends StatelessWidget {
  final scaffoldKey;

  PlutoMenuBarDemo({
    this.scaffoldKey,
  });

  void message(context, String text) {
    scaffoldKey.currentState.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(text),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          PlutoMenuBar(
            menus: [
              MenuItem(
                title: 'Menu 1',
                children: [
                  MenuItem(
                    title: 'Menu 1-1',
                    onTab: () => message(context, 'Menu 1-1 tap'),
                    children: [
                      MenuItem(
                        title: 'Menu 1-1-1',
                        onTab: () => message(context, 'Menu 1-1-1 tap'),
                        children: [
                          MenuItem(
                            title: 'Menu 1-1-1-1',
                            onTab: () => message(context, 'Menu 1-1-1-1 tap'),
                          ),
                          MenuItem(
                            title: 'Menu 1-1-1-2',
                            onTab: () => message(context, 'Menu 1-1-1-2 tap'),
                          ),
                        ],
                      ),
                      MenuItem(
                        title: 'Menu 1-1-2',
                        onTab: () => message(context, 'Menu 1-1-2 tap'),
                      ),
                    ],
                  ),
                  MenuItem(
                    title: 'Menu 1-2',
                    onTab: () => message(context, 'Menu 1-2 tap'),
                  ),
                ],
              ),
              MenuItem(
                title: 'Menu 2',
                children: [
                  MenuItem(
                    title: 'Menu 2-1',
                    onTab: () => message(context, 'Menu 2-1 tap'),
                  ),
                ],
              ),
              MenuItem(
                title: 'Menu 3',
                onTab: () => message(context, 'Menu 3 tap'),
              ),
              MenuItem(
                title: 'Menu 4',
                onTab: () => message(context, 'Menu 4 tap'),
              ),
              MenuItem(
                title: 'Menu 5',
                onTab: () => message(context, 'Menu 5 tap'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Coming soon
* Add theme