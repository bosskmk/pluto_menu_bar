// ignore_for_file: unused_element

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

  /// The scale of checkboxes and radio buttons.
  final double iconScale;

  /// The color of the unselected state of checkboxes and radio buttons.
  final Color unselectedColor;

  /// The color of the checkbox and radio button's selection state.
  final Color activatedColor;

  /// Check icon color for checkbox, radio button.
  final Color indicatorColor;

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
    this.iconScale = 0.86,
    this.unselectedColor = Colors.black26,
    this.activatedColor = Colors.lightBlue,
    this.indicatorColor = const Color(0xFFDCF5FF),
    this.moreIconColor = Colors.black54,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
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
                  unselectedColor: widget.unselectedColor,
                  activatedColor: widget.activatedColor,
                  indicatorColor: widget.indicatorColor,
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
  final String title;

  final IconData? icon;

  final bool enable;

  /// Callback executed when a menu is tapped
  final Function()? onTap;

  /// Passing [PlutoMenuItem] to a [List] creates a sub-menu.
  final List<PlutoMenuItem>? children;

  PlutoMenuItem({
    required this.title,
    this.icon,
    this.enable = true,
    this.onTap,
    this.children,
  }) : _key = GlobalKey();

  factory PlutoMenuItem.checkbox({
    required String title,
    IconData? icon,
    bool enable = false,
    void Function()? onTap,
    List<PlutoMenuItem>? children,
    void Function(bool?)? onChanged,
    bool? initialCheckValue,
  }) {
    return PlutoMenuItemCheckbox(
      title: title,
      icon: icon,
      enable: enable,
      onTap: onTap,
      children: children,
      onChanged: onChanged,
      initialCheckValue: initialCheckValue,
    );
  }

  static PlutoMenuItem radio({
    required String title,
    IconData? icon,
    bool enable = false,
    void Function()? onTap,
    required List<Object> radioItems,
    void Function(Object?)? onChanged,
    String Function(Object)? getTitle,
    Object? initialRadioValue,
  }) {
    return PlutoMenuItemRadio(
      title: title,
      icon: icon,
      enable: enable,
      onTap: onTap,
      radioItems: radioItems,
      onChanged: onChanged,
      getTitle: getTitle,
      initialRadioValue: initialRadioValue,
    );
  }

  static PlutoMenuItem divider({
    double height = 16.0,
    Color? color,
    double? indent,
    double? endIndent,
    double? thickness,
  }) {
    return PlutoMenuItemDivider(
      height: height,
      color: color,
      indent: indent,
      endIndent: endIndent,
      thickness: thickness,
    );
  }

  PlutoMenuItem._back({
    required this.title,
    this.icon,
    this.enable = true,
    this.onTap,
    this.children,
  })  : _key = GlobalKey(),
        _isBack = true;

  PlutoMenuItemType get type => PlutoMenuItemType.button;

  late final GlobalKey _key;

  bool _isBack = false;

  Offset get _position {
    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;

    return box.localToGlobal(Offset.zero);
  }

  bool get _hasChildren => children != null && children!.length > 0;
}

class PlutoMenuItemCheckbox extends PlutoMenuItem {
  PlutoMenuItemCheckbox({
    required super.title,
    super.icon,
    super.enable = true,
    super.onTap,
    super.children,
    this.onChanged,
    this.initialCheckValue,
  });

  PlutoMenuItemType get type => PlutoMenuItemType.checkbox;

  final Function(bool?)? onChanged;

  final bool? initialCheckValue;
}

class PlutoMenuItemRadio extends PlutoMenuItem {
  PlutoMenuItemRadio({
    required super.title,
    super.icon,
    super.enable = true,
    super.onTap,
    required this.radioItems,
    this.onChanged,
    this.getTitle,
    this.initialRadioValue,
  });

  PlutoMenuItemType get type => PlutoMenuItemType.radio;

  final Function(Object?)? onChanged;

  String Function(Object)? getTitle;

  final Object? initialRadioValue;

  final List<Object> radioItems;
}

class PlutoMenuItemDivider extends PlutoMenuItem {
  PlutoMenuItemDivider({
    this.height = 16.0,
    this.color,
    this.indent,
    this.endIndent,
    this.thickness,
  }) : super(title: '_divider', enable: false);

  PlutoMenuItemType get type => PlutoMenuItemType.divider;

  final double height;

  final Color? color;

  final double? indent;

  final double? endIndent;

  final double? thickness;
}

class _MenuWidget extends StatefulWidget {
  final PlutoMenuItem menu;

  final String goBackButtonText;

  final double? height;

  final Color? backgroundColor;

  final Color? menuIconColor;

  final double? menuIconSize;

  final Color? moreIconColor;

  final double iconScale;

  final Color unselectedColor;

  final Color activatedColor;

  final Color indicatorColor;

  final EdgeInsets? padding;

  final TextStyle? textStyle;

  final double offset;

  _MenuWidget(
    this.menu, {
    this.goBackButtonText = 'Go back',
    this.height,
    this.backgroundColor,
    this.menuIconColor,
    this.menuIconSize,
    this.moreIconColor,
    this.iconScale = 0.86,
    this.unselectedColor = Colors.black12,
    this.activatedColor = Colors.blue,
    this.indicatorColor = Colors.white,
    this.padding,
    this.textStyle,
    this.offset = 0,
  }) : super(key: menu._key);

  @override
  State<_MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<_MenuWidget> {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;

    super.dispose();
  }

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

    if (_disposed) {
      return Future.value();
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
    if (_disposed) {
      return Future.value();
    }

    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final Offset position = widget.menu._position + Offset(0, widget.height!);

    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + overlay.size.width,
        position.dy + overlay.size.height,
      ),
      items: menuItems.map((menu) {
        Widget menuItem;
        double height = kMinInteractiveDimension;
        EdgeInsets? padding;

        switch (menu.type) {
          case PlutoMenuItemType.button:
            menuItem = _buildButtonItem(menu);
            break;
          case PlutoMenuItemType.checkbox:
            menuItem = _buildCheckboxItem(menu);
            break;
          case PlutoMenuItemType.radio:
            menuItem = _buildRadioItem(menu);
            break;
          case PlutoMenuItemType.divider:
            menuItem = _buildDividerItem(menu as PlutoMenuItemDivider);
            height = menu.height;
            padding = EdgeInsets.only(left: 0, right: 0);
            break;
        }

        return PopupMenuItem<PlutoMenuItem>(
          value: menu,
          child: menuItem,
          enabled: menu.enable,
          height: height,
          padding: padding,
        );
      }).toList(),
      elevation: 2.0,
      color: widget.backgroundColor,
      useRootNavigator: true,
    );
  }

  Widget _buildButtonItem(PlutoMenuItem _menu) {
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
          child: Text(
            _menu.title,
            style: widget.textStyle,
            maxLines: 1,
            overflow: TextOverflow.visible,
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

  Widget _buildCheckboxItem(PlutoMenuItem _menu) {
    final checkboxItem = _menu as PlutoMenuItemCheckbox;
    bool? checked = checkboxItem.initialCheckValue;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StatefulBuilder(
          builder: (_, setState) {
            return Transform.scale(
              scale: widget.iconScale,
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: widget.unselectedColor,
                ),
                child: Checkbox(
                  value: checked,
                  activeColor: widget.activatedColor,
                  checkColor: widget.indicatorColor,
                  onChanged: (flag) {
                    setState(() {
                      checked = flag;

                      if (checkboxItem.onChanged != null) {
                        checkboxItem.onChanged!(flag);
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Text(
            _menu.title,
            style: widget.textStyle,
            maxLines: 1,
            overflow: TextOverflow.visible,
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

  Widget _buildRadioItem(PlutoMenuItem _menu) {
    final radioItem = _menu as PlutoMenuItemRadio;
    Object? selectedItem = radioItem.initialRadioValue;
    return StatefulBuilder(
      builder: (_, setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: radioItem.radioItems.map<Widget>((e) {
            final String title = radioItem.getTitle == null
                ? e.toString()
                : radioItem.getTitle!(e);

            return ListTile(
              title: Text(title, style: widget.textStyle),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
              leading: Transform.scale(
                scale: widget.iconScale,
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: widget.unselectedColor,
                  ),
                  child: Radio<Object>(
                    value: e,
                    groupValue: selectedItem,
                    activeColor: widget.activatedColor,
                    onChanged: (changed) {
                      setState(() {
                        selectedItem = changed;

                        if (radioItem.onChanged != null) {
                          radioItem.onChanged!(changed);
                        }
                      });
                    },
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _buildDividerItem(PlutoMenuItem _menu) {
    final dividerItem = _menu as PlutoMenuItemDivider;

    return Divider(
      color: dividerItem.color,
      indent: dividerItem.indent,
      endIndent: dividerItem.endIndent,
      thickness: dividerItem.thickness,
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
              widget.menu.title,
              style: widget.textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

enum PlutoMenuItemType {
  button,
  checkbox,
  radio,
  divider,
}
