// ignore_for_file: unused_element

import 'dart:collection';

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

  /// show the back button (default : true )
  final bool showBackButton;

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
    this.showBackButton = true,
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
                  showBackButton: widget.showBackButton,
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
  }) : _key = GlobalKey() {
    _setParent();
  }

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

  final GlobalKey _key;

  bool _isBack = false;

  Offset get _position {
    if (_key.currentContext == null) return Offset.zero;

    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;

    return box.localToGlobal(Offset.zero);
  }

  Size get _size {
    if (_key.currentContext == null) return Size.zero;

    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;

    return box.size;
  }

  bool get _hasChildren => children != null && children!.length > 0;

  PlutoMenuItem? _parent;

  void _setParent() {
    if (!_hasChildren) return;
    children!.forEach((e) => e._parent = this);
  }
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

  final bool showBackButton;

  final double height;

  final Color backgroundColor;

  final Color menuIconColor;

  final double menuIconSize;

  final Color moreIconColor;

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
    this.showBackButton = true,
    this.height = 45,
    this.backgroundColor = Colors.white,
    this.menuIconColor = Colors.black54,
    this.menuIconSize = 20,
    this.moreIconColor = Colors.black54,
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

  SplayTreeMap<String, OverlayEntry> _popups = SplayTreeMap();

  Set<String> _hoveredPopupKey = {};

  @override
  void dispose() {
    _disposed = true;

    super.dispose();
  }

  void openMenu(PlutoMenuItem menu) async {
    if (widget.menu._hasChildren) {
      showSubMenu(widget.menu);
    } else if (widget.menu.onTap != null) {
      widget.menu.onTap!();
    }
  }

  void showSubMenu(
    PlutoMenuItem menu, {
    PlutoMenuItem? previousMenu,
    int? stackIdx,
    List<PlutoMenuItem>? stack,
  }) async {
    if (!menu._hasChildren) {
      return;
    }

    if (_disposed) {
      return;
    }

    final items = [...menu.children!];

    if (previousMenu != null) {
      if (widget.showBackButton)
        items.add(PlutoMenuItem._back(
          title: widget.goBackButtonText,
          children: previousMenu.children,
        ));
    }

    _showPopupMenu(
      menu,
      context,
      items,
    );
  }

  void _showPopupMenu(
    PlutoMenuItem menu,
    BuildContext context,
    List<PlutoMenuItem> menuItems,
  ) async {
    if (_disposed) {
      return;
    }

    if (_popups.containsKey(menu._key.toString())) return;

    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final Offset menuPosition = menu._position;
    final Size menuSize = menu._size;
    final bool rootMenu = menu._parent == null;
    final Offset positionOffset = rootMenu
        ? Offset(0, widget.height)
        : Offset(
            menuSize.width - 10,
            10,
          );

    Offset position = menuPosition + positionOffset;
    double? top = position.dy;
    double? left = position.dx;
    double? right;
    double? bottom;

    if (position.dx + menuSize.width > overlay.size.width) {
      if (rootMenu) {
        left = null;
        right = 0;
      } else {
        left = null;
        right = overlay.size.width - menuPosition.dx;
      }
    }

    _popups[menu._key.toString()] = OverlayEntry(
      builder: (c) {
        return Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: Material(
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(overlay.size),
              child: MouseRegion(
                onHover: (event) async {
                  _hoveredPopupKey.add(menu._key.toString());
                  var current = menu._parent;
                  while (current != null) {
                    _hoveredPopupKey.add(current._key.toString());
                    current = current._parent;
                  }
                },
                onExit: (event) {
                  _hoveredPopupKey.clear();
                  Future.delayed(const Duration(milliseconds: 60), () {
                    if (!_hoveredPopupKey.contains(menu._key.toString())) {
                      _popups[menu._key.toString()]?.remove();
                      _popups.remove(menu._key.toString());
                    }

                    if (_hoveredPopupKey.isEmpty) {
                      _popups.forEach((k, v) => v.remove());
                      _popups.clear();
                    }
                  });
                },
                child: IntrinsicWidth(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: menuItems.map((item) {
                        Widget menuItem;
                        switch (item.type) {
                          case PlutoMenuItemType.button:
                            menuItem = _buildButtonItem(item);
                            break;
                          case PlutoMenuItemType.checkbox:
                            menuItem = _buildCheckboxItem(item);
                            break;
                          case PlutoMenuItemType.radio:
                            menuItem = _buildRadioItem(item);
                            break;
                          case PlutoMenuItemType.divider:
                            menuItem = _buildDividerItem(item);
                            break;
                        }
                        return menuItem;
                      }).toList()),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context)!.insert(_popups[menu._key.toString()]!);
  }

  Widget _buildButtonItem(PlutoMenuItem _menu) {
    final currentPopupKey = _menu._key.toString();
    return InkWell(
      onTap: _menu.onTap,
      key: _menu._key,
      child: ColoredBox(
        color: widget.backgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: MouseRegion(
            onHover: (event) async {
              if (_menu._hasChildren) {
                _hoveredPopupKey.add(_menu._key.toString());
                var current = _menu._parent;
                while (current != null) {
                  _hoveredPopupKey.add(current._key.toString());
                  current = current._parent;
                }

                Future.delayed(const Duration(milliseconds: 30), () {
                  showSubMenu(_menu);
                });
              }
            },
            onExit: (event) {
              if (_menu._hasChildren) {
                _hoveredPopupKey.clear();
                Future.delayed(const Duration(milliseconds: 60), () {
                  if (!_hoveredPopupKey.contains(currentPopupKey)) {
                    _popups[currentPopupKey]?.remove();
                    _popups.remove(currentPopupKey);
                  }

                  if (_hoveredPopupKey.isEmpty) {
                    _popups.forEach((k, v) => v.remove());
                    _popups.clear();
                  }
                });
              }
            },
            child: Row(
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
                if (_menu._hasChildren)
                  Icon(
                    Icons.arrow_right,
                    color: widget.moreIconColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(PlutoMenuItem _menu) {
    final checkboxItem = _menu as PlutoMenuItemCheckbox;
    bool? checked = checkboxItem.initialCheckValue;
    return ColoredBox(
      color: widget.backgroundColor,
      child: Row(
        key: _menu._key,
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
      ),
    );
  }

  Widget _buildRadioItem(PlutoMenuItem _menu) {
    final radioItem = _menu as PlutoMenuItemRadio;
    Object? selectedItem = radioItem.initialRadioValue;
    return ColoredBox(
      color: widget.backgroundColor,
      child: StatefulBuilder(
        key: _menu._key,
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
      ),
    );
  }

  Widget _buildDividerItem(PlutoMenuItem _menu) {
    final dividerItem = _menu as PlutoMenuItemDivider;

    return ColoredBox(
      color: widget.backgroundColor,
      child: Divider(
        key: _menu._key,
        color: dividerItem.color,
        indent: dividerItem.indent,
        endIndent: dividerItem.endIndent,
        thickness: dividerItem.thickness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: MouseRegion(
        onHover: (event) async {
          _hoveredPopupKey.clear();

          if (!widget.menu._hasChildren) return;

          var current = widget.menu._parent;
          while (current != null) {
            _hoveredPopupKey.add(current._key.toString());
            current = current._parent;
          }

          Future.delayed(const Duration(milliseconds: 30), () {
            showSubMenu(widget.menu);
          });
        },
        onExit: (event) {
          _hoveredPopupKey.clear();
          Future.delayed(const Duration(milliseconds: 60), () {
            if (!_hoveredPopupKey.contains(widget.menu._key.toString())) {
              _popups[widget.menu._key.toString()]?.remove();
              _popups.remove(widget.menu._key.toString());
            }

            if (_hoveredPopupKey.isEmpty) {
              _popups.forEach((k, v) => v.remove());
              _popups.clear();
            }
          });
        },
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
