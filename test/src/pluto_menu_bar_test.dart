import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

void main() {
  testWidgets('create menu bar', (WidgetTester tester) async {
    // given
    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'menu1',
                  onTab: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // then
    final menu = find.text('menu1');
    expect(menu, findsOneWidget);
  });
}