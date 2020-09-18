import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

import '../mock/mock_handle.dart';

void main() {
  testWidgets('When menus is null, Then failed creating menu bar',
      (WidgetTester tester) async {
    // given
    // when
    // then
    expect(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoMenuBar(
                menus: null,
              ),
            ),
          ),
        ),
      );
    }, throwsAssertionError);
  });

  testWidgets('When menus length is zero, Then failed creating menu bar',
          (WidgetTester tester) async {
        // given
        // when
        // then
        expect(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: Container(
                  child: PlutoMenuBar(
                    menus: [],
                  ),
                ),
              ),
            ),
          );
        }, throwsAssertionError);
      });

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
                  title: 'Menu1',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // then
    final menu = find.text('Menu1');
    expect(menu, findsOneWidget);
  });

  testWidgets('create sub-menu bar', (WidgetTester tester) async {
    // given
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  children: [
                    MenuItem(title: 'Menu 1-1', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    final menu1_1 = find.text('Menu 1-1');
    expect(menu1_1, findsOneWidget);
  });

  testWidgets('tap menu bar', (WidgetTester tester) async {
    // given
    final handle = MockHandle();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  onTap: handle.onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    verify(handle.onTap()).called(1);
  });

  testWidgets('tap sub-menu bar', (WidgetTester tester) async {
    // given
    final handle1 = MockHandle();
    final handle2 = MockHandle();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  children: [
                    MenuItem(title: 'Menu 1-1', onTap: handle1.onTap),
                    MenuItem(title: 'Menu 1-2', onTap: handle2.onTap),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    verifyNever(handle1.onTap());
    verifyNever(handle2.onTap());

    Finder menu1_1 = find.text('Menu 1-1');
    await tester.tap(menu1_1);

    // then
    verify(handle1.onTap()).called(1);
    verifyNever(handle2.onTap());
  });

  testWidgets(
      'When tap the sub-menu has not as sub-menu '
      'Then the back button is not exists.', (WidgetTester tester) async {
    // given
    final handle = MockHandle();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  children: [
                    MenuItem(
                      title: 'Menu 1-1',
                      children: [
                        MenuItem(
                          title: 'Menu 1-1-1',
                          onTap: handle.onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    Finder menu1_1 = find.text('Menu 1-1');
    await tester.tap(menu1_1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    Finder menu1_1_1 = find.text('Menu 1-1-1');
    await tester.tap(menu1_1_1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    Finder back = find.text('Go back');
    expect(back, findsNothing);
  });

  testWidgets(
      'When tap the sub-menu has as sub-menu '
      'Then the back button appears.', (WidgetTester tester) async {
    // given
    final handle = MockHandle();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  children: [
                    MenuItem(
                      title: 'Menu 1-1',
                      children: [
                        MenuItem(
                          title: 'Menu 1-1-1',
                          onTap: handle.onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    Finder menu1_1 = find.text('Menu 1-1');
    await tester.tap(menu1_1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    Finder back = find.text('Go back');
    expect(back, findsOneWidget);
  });

  testWidgets(
      'When tap the back button '
      'Then the current menu disappeared.', (WidgetTester tester) async {
    // given
    final handle = MockHandle();

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoMenuBar(
              menus: [
                MenuItem(
                  title: 'Menu1',
                  children: [
                    MenuItem(
                      title: 'Menu 1-1',
                      children: [
                        MenuItem(
                          title: 'Menu 1-1-1',
                          onTap: handle.onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    Finder menu1 = find.text('Menu1');
    await tester.tap(menu1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    Finder menu1_1 = find.text('Menu 1-1');
    await tester.tap(menu1_1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    expect(menu1_1, findsNothing);

    Finder menu1_1_1 = find.text('Menu 1-1-1');
    expect(menu1_1_1, findsOneWidget);

    Finder back = find.text('Go back');
    await tester.tap(back);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(menu1_1_1, findsNothing);

    expect(menu1_1, findsOneWidget);
  });
}
