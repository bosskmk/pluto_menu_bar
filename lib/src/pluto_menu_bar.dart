import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PlutoMenuBar extends StatefulWidget {
  /// Pass [PlutoMenuItem] to List.
  /// create submenus by continuing to pass MenuItem to children as a List.
  ///
  /// ```dart
  /// MenuItem(
  ///   title: 'Menu 1',
  ///   children: [
  ///     MenuItem(
  ///       title: 'Menu 1-1',
  ///       onTap: () => print('Menu 1-1 tap'),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final List<PlutoMenuItem> menus;

  /// Text of the back button. (default. 'Go back')
  final String goBackButtonText;

  /// menu height. (default. '45')
  final double height;

  /// BackgroundColor. (default. 'white')
  final Color backgroundColor;

  /// Border color. (default. 'black12')
  final Color borderColor;

  /// menu icon color. (default. 'black54')
  final Color menuIconColor;

  /// menu icon size. (default. '20')
  final double menuIconSize;

  /// more icon color. (default. 'black54')
  final Color moreIconColor;

  /// [TextStyle] of Menu title.
  final TextStyle textStyle;

  final EdgeInsets menuPadding;

  PlutoMenuBar({
    required this.menus,
    this.goBackButtonText = 'Go back',
    this.height = 45,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black12,
    this.menuIconColor = Colors.black54,
    this.menuIconSize = 20,
    this.moreIconColor = Colors.black54,
    this.textStyle = const TextStyle(),
    this.menuPadding = const EdgeInsets.symmetric(horizontal: 15),
  }) : assert(menus.length > 0);

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
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border(
              top: BorderSide(color: widget.borderColor),
              bottom: BorderSide(color: widget.borderColor),
            ),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.menus.length,
              itemBuilder: (_, index) {
                return _MenuWidget(
                  widget.menus[index],
                  goBackButtonText: widget.goBackButtonText,
                  height: widget.height,
                  padding: widget.menuPadding,
                  backgroundColor: widget.backgroundColor,
                  menuIconColor: widget.menuIconColor,
                  menuIconSize: widget.menuIconSize,
                  moreIconColor: widget.moreIconColor,
                  textStyle: widget.textStyle,
                  offset: widget.menuPadding.left,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class PlutoMenuItem {
  /// Menu title
  final String? title;

  final IconData? icon;

  /// Callback executed when a menu is tapped
  final Function()? onTap;

  /// Passing [PlutoMenuItem] to a [List] creates a sub-menu.
  final List<PlutoMenuItem>? children;

  PlutoMenuItem({
    this.title,
    this.icon,
    this.onTap,
    this.children,
  }) : _key = GlobalKey();

  PlutoMenuItem._back({
    this.title,
    // ignore: unused_element
    this.icon,
    // ignore: unused_element
    this.onTap,
    this.children,
  })  : _key = GlobalKey(),
        _isBack = true;

  GlobalKey _key;

  bool _isBack = false;

  Offset get _position {
    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;

    return box.localToGlobal(Offset.zero);
  }

  bool get _hasChildren => children != null && children!.length > 0;
}

class _MenuWidget extends StatefulWidget {
  final PlutoMenuItem menu;

  final String? goBackButtonText;

  final double? height;

  final Color? backgroundColor;

  final Color? menuIconColor;

  final double? menuIconSize;

  final Color? moreIconColor;

  final EdgeInsets? padding;

  final TextStyle? textStyle;

  final double offset;

  _MenuWidget(
    this.menu, {
    this.goBackButtonText,
    this.height,
    this.backgroundColor,
    this.menuIconColor,
    this.menuIconSize,
    this.moreIconColor,
    this.padding,
    this.textStyle,
    this.offset = 0,
  }) : super(key: menu._key);

  @override
  State<_MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<_MenuWidget> {
  void openMenu(PlutoMenuItem menu) async {
    if (widget.menu._hasChildren) {
      PlutoMenuItem? selectedMenu = await showSubMenu(widget.menu);

      if (selectedMenu?.onTap != null) {
        selectedMenu!.onTap!();
      }
    } else if (widget.menu.onTap != null) {
      widget.menu.onTap!();
    }
  }

  Future<PlutoMenuItem?> showSubMenu(
    PlutoMenuItem menu, {
    PlutoMenuItem? previousMenu,
    int? stackIdx,
    List<PlutoMenuItem>? stack,
  }) async {
    if (!menu._hasChildren) {
      return menu;
    }

    final items = [...menu.children!];

    if (previousMenu != null) {
      items.add(PlutoMenuItem._back(
        title: widget.goBackButtonText,
        children: previousMenu.children,
      ));
    }

    PlutoMenuItem? _selectedMenu = await _showPopupMenu(
      context,
      items,
    );

    if (_selectedMenu == null) {
      return null;
    }

    PlutoMenuItem? _previousMenu = menu;

    if (!_selectedMenu._hasChildren) {
      return _selectedMenu;
    }

    if (_selectedMenu._isBack) {
      stackIdx ??= 0;
      --stackIdx;
      if (stackIdx < 0) {
        _previousMenu = null;
      } else {
        _previousMenu = stack![stackIdx];
      }
    } else {
      if (stackIdx == null) {
        stackIdx = 0;
        stack = [menu];
      } else {
        stackIdx += 1;
        stack!.add(menu);
      }
    }

    return await showSubMenu(
      _selectedMenu,
      previousMenu: _previousMenu,
      stackIdx: stackIdx,
      stack: stack,
    );
  }

  Future<PlutoMenuItem?> _showPopupMenu(
    BuildContext context,
    List<PlutoMenuItem> menuItems,
  ) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final Offset position =
        widget.menu._position + Offset(-widget.offset, widget.height! - 1);

    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width,
        overlay.size.height,
      ),
      items: menuItems.map((menu) {
        return PopupMenuItem<PlutoMenuItem>(
          value: menu,
          child: _buildPopupItem(menu),
        );
      }).toList(),
      elevation: 2.0,
      color: widget.backgroundColor,
    );
  }

  Widget _buildPopupItem(PlutoMenuItem _menu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_menu.icon != null) ...[
          Icon(
            _menu.icon,
            color: widget.menuIconColor,
            size: widget.menuIconSize,
          ),
          SizedBox(
            width: 5,
          ),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              _menu.title!,
              style: widget.textStyle,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (_menu._hasChildren && !_menu._isBack)
          Icon(
            Icons.arrow_right,
            color: widget.moreIconColor,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: InkWell(
        onTap: () async {
          openMenu(widget.menu);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.menu.icon != null) ...[
              Icon(
                widget.menu.icon,
                color: widget.menuIconColor,
                size: widget.menuIconSize,
              ),
              SizedBox(
                width: 5,
              ),
            ],
            Text(
              widget.menu.title!,
              style: widget.textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
