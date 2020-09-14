part of '../pluto_menu_bar.dart';

class PlutoMenuBar extends StatefulWidget {
  /// Pass [MenuItem] to List.
  /// create submenus by continuing to pass MenuItem to children as a List.
  ///
  /// ```dart
  /// MenuItem(
  ///   title: 'Menu 1',
  ///   children: [
  ///     MenuItem(
  ///       title: 'Menu 1-1',
  ///       onTab: () => print('Menu 1-1 tap'),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final List<MenuItem> menus;

  /// Text of the back button. (default. 'Go back')
  final String goBackButtonText;

  PlutoMenuBar({
    this.menus,
    this.goBackButtonText = 'Go back',
  });

  @override
  _PlutoMenuBarState createState() => _PlutoMenuBarState();
}

class _PlutoMenuBarState extends State<PlutoMenuBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, size) {
        return Container(
          width: size.maxWidth,
          height: 45,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white54,
              ],
              stops: [0.90, 1],
            ),
            border: Border(
              top: BorderSide(color: Colors.black12),
              bottom: BorderSide(color: Colors.black12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 0.5), // changes position of shadow
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.menus.length,
            itemBuilder: (_, index) {
              return _MenuWidget(
                widget.menus[index],
                goBackButtonText: widget.goBackButtonText,
              );
            },
          ),
        );
      },
    );
  }
}

class MenuItem {
  /// Menu title
  final String title;

  /// Callback executed when a menu is tapped
  final Function() onTab;

  /// Passing [MenuItem] to a [List] creates a sub-menu.
  final List<MenuItem> children;

  MenuItem({
    this.title,
    this.onTab,
    this.children,
  }) : _key = GlobalKey();

  MenuItem._back({
    this.title,
    this.onTab,
    this.children,
  })  : _key = GlobalKey(),
        _isBack = true;

  GlobalKey _key;

  bool _isBack = false;

  Offset get _position {
    RenderBox box = _key.currentContext.findRenderObject();

    return box.localToGlobal(Offset.zero);
  }

  bool get _hasChildren => children != null && children.length > 0;
}

class _MenuWidget extends StatelessWidget {
  final MenuItem menu;

  final String goBackButtonText;

  _MenuWidget(
    this.menu, {
    this.goBackButtonText,
  }) : super(key: menu._key);

  Widget _buildPopupItem(MenuItem _menu) {
    return _menu._hasChildren && !_menu._isBack
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_menu.title),
              Icon(
                Icons.arrow_right,
                color: Colors.black54,
              ),
            ],
          )
        : Text(_menu.title);
  }

  Future<MenuItem> _showPopupMenu(
    BuildContext context,
    List<MenuItem> menuItems,
  ) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    final Offset position = menu._position + Offset(0, 34);

    return await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: menuItems.map((menu) {
        return PopupMenuItem<MenuItem>(
          value: menu,
          child: _buildPopupItem(menu),
        );
      }).toList(),
      elevation: 2.0,
    );
  }

  Widget _getMenu(
    BuildContext context,
    MenuItem menu,
  ) {
    Future<MenuItem> _getSelectedMenu(
      MenuItem menu, {
      MenuItem previousMenu,
      int stackIdx,
      List<MenuItem> stack,
    }) async {
      if (!menu._hasChildren) {
        return menu;
      }

      final items = [...menu.children];

      if (previousMenu != null) {
        items.add(MenuItem._back(
          title: goBackButtonText,
          children: previousMenu.children,
        ));
      }

      MenuItem _selectedMenu = await _showPopupMenu(
        context,
        items,
      );

      if (_selectedMenu == null) {
        return null;
      }

      MenuItem _previousMenu = menu;

      if (!_selectedMenu._hasChildren) {
        return _selectedMenu;
      }

      if (_selectedMenu._isBack) {
        --stackIdx;
        if (stackIdx < 0) {
          _previousMenu = null;
        } else {
          _previousMenu = stack[stackIdx];
        }
      } else {
        if (stackIdx == null) {
          stackIdx = 0;
          stack = [menu];
        } else {
          stackIdx += 1;
          stack.add(menu);
        }
      }

      return await _getSelectedMenu(
        _selectedMenu,
        previousMenu: _previousMenu,
        stackIdx: stackIdx,
        stack: stack,
      );
    }

    return InkWell(
      onTap: () async {
        if (menu._hasChildren) {
          MenuItem selectedMenu = await _getSelectedMenu(menu);

          if (selectedMenu?.onTab != null) {
            selectedMenu.onTab();
          }
        } else if (menu?.onTab != null) {
          menu.onTab();
        }
      },
      child: _MenuTitleWidget(menu.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getMenu(context, menu);
  }
}

class _MenuTitleWidget extends StatelessWidget {
  final String title;

  _MenuTitleWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.center,
        child: Text(title),
      ),
    );
  }
}
