import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

import '../mock/mock_methods.dart';

void main() {
  final mock = MockMethods();

  tearDown(() {
    reset(mock);
  });

  Future<void> buildWidget(
    WidgetTester tester, {
    required List<PlutoMenuItem> menus,
    String goBackButtonText = 'Go back',
    bool showBackButton = true,
    double height = 45,
    PlutoMenuBarMode mode = PlutoMenuBarMode.tap,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: PlutoMenuBar(
          menus: menus,
          goBackButtonText: goBackButtonText,
          showBackButton: showBackButton,
          height: height,
          mode: mode,
        ),
      ),
    ));
  }

  group('PlutoMenuBarMode.tap', () {
    final PlutoMenuBarMode mode = PlutoMenuBarMode.tap;

    Future<void> buildTapMode(
      WidgetTester tester,
      List<PlutoMenuItem> menus,
    ) async {
      await buildWidget(tester, menus: menus, mode: mode);
    }

    testWidgets('메뉴의 제목들이 렌더링 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(title: 'menu1'),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildTapMode(tester, menus);

      expect(find.text('menu1'), findsOneWidget);
      expect(find.text('menu2'), findsOneWidget);
      expect(find.text('menu3'), findsOneWidget);
    });

    testWidgets('메뉴1을 탭하면 onTab 콜백이 호출 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(title: 'menu1', onTap: mock.noParamReturnVoid),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildTapMode(tester, menus);

      await tester.tap(find.text('menu1'));

      verify(mock.noParamReturnVoid()).called(1);
    });

    testWidgets('메뉴1을 탭하면 children 메뉴들이 렌더링 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(
          title: 'menu1',
          children: [
            PlutoMenuItem(title: 'menu1-1'),
            PlutoMenuItem(title: 'menu1-2'),
          ],
        ),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildTapMode(tester, menus);

      await tester.tap(find.text('menu1'));
      await tester.pump();

      expect(find.text('menu1-1'), findsOneWidget);
      expect(find.text('menu1-2'), findsOneWidget);
    });

    testWidgets('메뉴1-1을 탭하면 Go back 버튼이 렌더링 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(
          title: 'menu1',
          children: [
            PlutoMenuItem(
              title: 'menu1-1',
              children: [
                PlutoMenuItem(title: 'menu1-1-1'),
                PlutoMenuItem(title: 'menu1-1-2'),
              ],
            ),
            PlutoMenuItem(title: 'menu1-2'),
          ],
        ),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildTapMode(tester, menus);

      await tester.tap(find.text('menu1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('menu1-1'));
      await tester.pumpAndSettle();

      expect(find.text('Go back'), findsOneWidget);
    });

    testWidgets(
      '메뉴1-1을 탭하면 메뉴1-1의 자식들이 렌더링 되고, '
      'Go back 버튼을 탭하면 메뉴 1-1의 자식들이 사라지고 메뉴1의 자식들이 렌더링 되어야 한다.',
      (tester) async {
        final menus = [
          PlutoMenuItem(
            title: 'menu1',
            children: [
              PlutoMenuItem(
                title: 'menu1-1',
                children: [
                  PlutoMenuItem(title: 'menu1-1-1'),
                  PlutoMenuItem(title: 'menu1-1-2'),
                ],
              ),
              PlutoMenuItem(title: 'menu1-2'),
            ],
          ),
          PlutoMenuItem(title: 'menu2'),
          PlutoMenuItem(title: 'menu3'),
        ];

        await buildTapMode(tester, menus);

        await tester.tap(find.text('menu1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('menu1-1'));
        await tester.pumpAndSettle();

        expect(find.text('menu1-1-1'), findsOneWidget);
        expect(find.text('menu1-1-2'), findsOneWidget);

        await tester.tap(find.text('Go back'));
        await tester.pumpAndSettle();

        expect(find.text('menu1-1-1'), findsNothing);
        expect(find.text('menu1-1-2'), findsNothing);
        expect(find.text('Go back'), findsNothing);

        expect(find.text('menu1-1'), findsOneWidget);
        expect(find.text('menu1-2'), findsOneWidget);
      },
    );

    testWidgets('메뉴1과 메뉴1-1을 탭하면 메뉴1-1의 onTap 콜백이 호출 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(
          title: 'menu1',
          children: [
            PlutoMenuItem(title: 'menu1-1', onTap: mock.noParamReturnVoid),
            PlutoMenuItem(title: 'menu1-2'),
          ],
        ),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildTapMode(tester, menus);

      await tester.tap(find.text('menu1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('menu1-1'));
      await tester.pump();

      verify(mock.noParamReturnVoid()).called(1);
    });
  });

  group('PlutoMenuBarMode.hover', () {
    final PlutoMenuBarMode mode = PlutoMenuBarMode.hover;

    Future<void> buildHoverMode(
      WidgetTester tester,
      List<PlutoMenuItem> menus,
    ) async {
      await buildWidget(tester, menus: menus, mode: mode);
    }

    testWidgets('메뉴의 제목들이 렌더링 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(title: 'menu1'),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildHoverMode(tester, menus);

      expect(find.text('menu1'), findsOneWidget);
      expect(find.text('menu2'), findsOneWidget);
      expect(find.text('menu3'), findsOneWidget);
    });

    testWidgets('메뉴1을 탭하면 onTab 콜백이 호출 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(title: 'menu1', onTap: mock.noParamReturnVoid),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildHoverMode(tester, menus);

      await tester.tap(find.text('menu1'));

      verify(mock.noParamReturnVoid()).called(1);
    });

    testWidgets('메뉴1을 호버하면 메뉴1의 자식들이 렌더링 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(
          title: 'menu1',
          children: [
            PlutoMenuItem(title: 'menu1-1'),
            PlutoMenuItem(title: 'menu1-2'),
          ],
        ),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildHoverMode(tester, menus);

      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('menu1')));
      await tester.pumpAndSettle();

      expect(find.text('menu1-1'), findsOneWidget);
      expect(find.text('menu1-2'), findsOneWidget);
    });

    testWidgets(
      '메뉴1을 호버하면 메뉴1의 자식들이 렌더링되고, '
      '메뉴2를 호버하면 메뉴1의 자식들이 사라지고 메뉴2의 자식들이 렌더링 되어야 한다.',
      (tester) async {
        final menus = [
          PlutoMenuItem(
            title: 'menu1',
            children: [
              PlutoMenuItem(title: 'menu1-1'),
              PlutoMenuItem(title: 'menu1-2'),
            ],
          ),
          PlutoMenuItem(
            title: 'menu2',
            children: [
              PlutoMenuItem(title: 'menu2-1'),
              PlutoMenuItem(title: 'menu2-2'),
            ],
          ),
          PlutoMenuItem(title: 'menu3'),
        ];

        await buildHoverMode(tester, menus);

        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.text('menu1')));
        await tester.pumpAndSettle();

        expect(find.text('menu1-1'), findsOneWidget);
        expect(find.text('menu1-2'), findsOneWidget);

        await gesture.moveTo(tester.getCenter(find.text('menu2')));
        await tester.pumpAndSettle();

        expect(find.text('menu1-1'), findsNothing);
        expect(find.text('menu1-2'), findsNothing);

        expect(find.text('menu2-1'), findsOneWidget);
        expect(find.text('menu2-2'), findsOneWidget);
      },
    );

    testWidgets('메뉴1을 호버후 메뉴1-2을 탭하면 onTap 콜백이 호출 되어야 한다.', (tester) async {
      final menus = [
        PlutoMenuItem(
          title: 'menu1',
          children: [
            PlutoMenuItem(title: 'menu1-1'),
            PlutoMenuItem(title: 'menu1-2', onTap: mock.noParamReturnVoid),
          ],
        ),
        PlutoMenuItem(title: 'menu2'),
        PlutoMenuItem(title: 'menu3'),
      ];

      await buildHoverMode(tester, menus);

      final TestGesture gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('menu1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('menu1-2'));

      verify(mock.noParamReturnVoid()).called(1);
    });
  });
}
