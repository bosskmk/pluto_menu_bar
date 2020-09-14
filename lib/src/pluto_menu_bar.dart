part of '../pluto_menu_bar.dart';

class PlutoMenuBar extends StatefulWidget {
  final List<MenuItem> menus;

  PlutoMenuBar({this.menus});

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
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white54,
              ],
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
              return MenuWidget(widget.menus[index]);
            },
          ),
        );
      },
    );
  }
}

class MenuItem {
  final String title;
  final Function() onTab;
  final List<MenuItem> children;

  MenuItem({
    this.title,
    this.onTab,
    this.children,
  });

  bool get hasChildren => children != null && children.length > 0;
}

class MenuWidget extends StatelessWidget {
  final MenuItem menu;

  MenuWidget(this.menu);

  Future<MenuItem> _showPopupMenu(
    BuildContext context,
    List<MenuItem> menuItems,
  ) async {
    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        ...menuItems.map((menu) {
          return PopupMenuItem<MenuItem>(
            value: menu,
            child: Text(menu.title),
          );
        }).toList(),
      ],
      elevation: 8.0,
    );
  }

  Widget _getMenu(
    BuildContext context,
    MenuItem menu,
  ) {
    Future<MenuItem> _getSelectedMenu(MenuItem menu) async {
      if (menu.hasChildren) {
        var selectedMenu = await _showPopupMenu(
          context,
          menu.children,
        );

        if (selectedMenu == null) {
          return menu;
        }

        if (selectedMenu.hasChildren) {
          selectedMenu = await _getSelectedMenu(selectedMenu);
        }

        return selectedMenu;
      }

      return menu;
    }

    return InkWell(
      onTap: () async {
        if (menu.hasChildren) {
          MenuItem selectedMenu = await _getSelectedMenu(menu);

          if (selectedMenu?.onTab != null) {
            selectedMenu.onTab();
          }
        } else if (menu?.onTab != null) {
          menu.onTab();
        }
      },
      child: MenuTitleWidget(menu.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getMenu(context, menu);
  }
}

class MenuTitleWidget extends StatelessWidget {
  final String title;

  MenuTitleWidget(this.title);

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
