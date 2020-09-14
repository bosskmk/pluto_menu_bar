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
