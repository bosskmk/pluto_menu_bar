import 'package:flutter/material.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
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
                        onTab: () => print('Menu 1-1 tap'),
                        children: [
                          MenuItem(
                            title: 'Menu 1-1-1',
                            onTab: () => print('Menu 1-1-1 tap'),
                          ),
                          MenuItem(
                            title: 'Menu 1-1-2',
                            onTab: () => print('Menu 1-1-2 tap'),
                          ),
                        ],
                      ),
                      MenuItem(
                        title: 'Menu 1-2',
                        onTab: () => print('Menu 1-2 tap'),
                      ),
                    ],
                  ),
                  MenuItem(
                    title: 'Menu 2',
                    children: [
                      MenuItem(
                        title: 'Menu 2-1',
                        onTab: () => print('Menu 2-1 tap'),
                      ),
                    ],
                  ),
                  MenuItem(title: 'Menu 3'),
                  MenuItem(title: 'Menu 4'),
                  MenuItem(title: 'Menu 5'),
                  MenuItem(title: 'Menu 6'),
                  MenuItem(title: 'Menu 7'),
                  MenuItem(title: 'Menu 8'),
                  MenuItem(title: 'Menu 9'),
                  MenuItem(title: 'Menu 10'),
                  MenuItem(title: 'Menu 11'),
                  MenuItem(title: 'Menu 12'),
                  MenuItem(title: 'Menu 13'),
                  MenuItem(title: 'Menu 14'),
                  MenuItem(title: 'Menu 15'),
                  MenuItem(title: 'Menu 16'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
