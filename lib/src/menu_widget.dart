part of pluto_menu_bar;

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
