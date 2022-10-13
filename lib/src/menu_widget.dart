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

  final PlutoMenuBarMode mode;

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
    this.mode = PlutoMenuBarMode.tap,
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

    _hoveredPopupKey.clear();
    _popups.forEach((k, v) => v.remove());
    _popups.clear();

    super.dispose();
  }

  void openMenu(PlutoMenuItem menu) async {
    if (widget.menu._hasChildren) {
      if (widget.menu.onTap != null) {
        widget.menu.onTap!();
      }
      showSubMenu(widget.menu);
    } else if (widget.menu.onTap != null) {
      widget.menu.onTap!();
    }
  }

  void showSubMenu(PlutoMenuItem menu) async {
    if (!menu._hasChildren) return;
    if (_disposed) return;

    switch (widget.mode) {
      case PlutoMenuBarMode.hover:
        _showHoveredPopupMenu(menu, context, menu.children!);
        break;
      case PlutoMenuBarMode.tap:
        _showTappedPopupMenu(menu, context, menu.children!);
        break;
    }
  }

  void _showHoveredPopupMenu(
    PlutoMenuItem menu,
    BuildContext context,
    List<PlutoMenuItem> menuItems,
  ) {
    if (_disposed) return;
    if (_popups.containsKey(menu._key.toString())) return;

    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    const double itemMinWidth = 150.0;
    const double itemMinHeight = 43.0;
    final Offset menuPosition = menu._position - Offset(0, 1);
    final Size menuSize = menu._size;
    final bool rootMenu = menu._parent == null;
    final Offset positionOffset =
        rootMenu ? Offset(0, widget.height) : Offset(menuSize.width - 10, 10);

    Offset position = menuPosition + positionOffset;
    double? top = position.dy;
    double? left = position.dx;
    double? right;
    double? bottom;

    if (position.dx + itemMinWidth > overlay.size.width) {
      if (rootMenu) {
        left = null;
        right = 0;
      } else {
        left = null;
        right = overlay.size.width - menuPosition.dx;
        if (right + menuSize.width >= overlay.size.width) {
          top = menuPosition.dy + 30;
          bottom = null;
          left = menuPosition.dx <= 15 ? menuPosition.dx + 10 : 0;
          right = null;
        }
      }
    }

    if (position.dy + itemMinHeight * menuItems.length > overlay.size.height) {
      if (rootMenu) {
        top = null;
        bottom = 0;
      } else {
        top = null;
        bottom = overlay.size.height - menuPosition.dy;
        if (bottom + menuSize.height >= overlay.size.height) {
          top = menuPosition.dy + 30;
          bottom = null;
          top = menuPosition.dy <= 15 ? menuPosition.dy + 10 : 0;
          bottom = null;
        }
      }
    }

    _popups[menu._key.toString()] = OverlayEntry(
      builder: (_) {
        Widget buildItemWidget(item) {
          EdgeInsets padding = EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          );

          late Widget menuItemWidget;

          switch (item.type) {
            case PlutoMenuItemType.button:
              menuItemWidget = _buildButtonItem(item);
              break;
            case PlutoMenuItemType.checkbox:
              menuItemWidget = _buildCheckboxItem(item);
              padding = EdgeInsets.symmetric(vertical: 10);
              break;
            case PlutoMenuItemType.radio:
              menuItemWidget = _buildRadioItem(item);
              padding = EdgeInsets.symmetric(vertical: 10);
              break;
            case PlutoMenuItemType.divider:
              menuItemWidget = _buildDividerItem(item);
              break;
          }

          if (item.type.isDivider) {
            return menuItemWidget;
          }

          menuItemWidget = TextButton(
            onPressed: item.onTap,
            style: TextButton.styleFrom(textStyle: widget.textStyle),
            child: Padding(padding: padding, child: menuItemWidget),
          );

          if (!item._hasChildren) return menuItemWidget;

          onHoverItem(_) {
            _addHoveredPopupKey(item);
            _showSubMenuDelay(item);
          }

          onExitItem(_) => _removeHoveredPopupKey(item);

          return MouseRegion(
            onHover: onHoverItem,
            onExit: onExitItem,
            child: menuItemWidget,
          );
        }

        onHover(_) => _addHoveredPopupKey(menu);

        onExit(_) => _removeHoveredPopupKey(menu);

        final menuItemWidgets = menuItems.map(buildItemWidget).toList();

        return Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: Material(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: min(overlay.size.width, itemMinWidth),
                maxWidth: overlay.size.width,
                maxHeight: overlay.size.height - (top ?? 0),
              ),
              child: PhysicalModel(
                color: widget.backgroundColor,
                elevation: 2.0,
                child: MouseRegion(
                  onHover: onHover,
                  onExit: onExit,
                  child: IntrinsicWidth(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: menuItemWidgets,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context)!.insert(_popups[menu._key.toString()]!);
  }

  void _showTappedPopupMenu(
    PlutoMenuItem menu,
    BuildContext context,
    List<PlutoMenuItem> menuItems,
  ) {
    if (_disposed) {
      return;
    }

    final items = [...menuItems];

    if (widget.mode.isTap && widget.showBackButton && !menu._isRootSubMenu) {
      final backButton = PlutoMenuItem._back(
        title: widget.goBackButtonText,
        children: items.first._parent?._parent?.children,
      );
      backButton._parent = items.first._parent?._parent?._parent;
      items.add(backButton);
    }

    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final Offset position =
        widget.menu._position + Offset(0, widget.height - 1);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + overlay.size.width,
        position.dy + overlay.size.height,
      ),
      items: items.map((menu) {
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
    ).then((selectedMenu) async {
      if (selectedMenu == null) return;

      if (selectedMenu._hasChildren) {
        _showTappedPopupMenu(selectedMenu, context, selectedMenu.children!);
        return;
      }

      if (selectedMenu.onTap != null) {
        selectedMenu.onTap!();
      }
    });
  }

  Widget _buildButtonItem(PlutoMenuItem _menu) {
    return Row(
      key: _menu._key,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_menu.icon != null) ...[
          Icon(
            _menu.icon,
            color: widget.menuIconColor,
            size: widget.menuIconSize,
          ),
          SizedBox(width: 5),
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
          Icon(Icons.arrow_right, color: widget.moreIconColor),
      ],
    );
  }

  Widget _buildCheckboxItem(PlutoMenuItem _menu) {
    final checkboxItem = _menu as PlutoMenuItemCheckbox;
    bool? checked = checkboxItem.initialCheckValue;

    return Row(
      key: _menu._key,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StatefulBuilder(
          builder: (_, setState) {
            onChanged(flag) {
              updateCheckBox() {
                checked = flag;
                if (checkboxItem.onChanged == null) return;
                checkboxItem.onChanged!(flag);
              }

              setState(updateCheckBox);
            }

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
                  visualDensity: VisualDensity(vertical: -4),
                  onChanged: onChanged,
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
          Icon(Icons.arrow_right, color: widget.moreIconColor),
      ],
    );
  }

  Widget _buildRadioItem(PlutoMenuItem _menu) {
    final radioItem = _menu as PlutoMenuItemRadio;
    Object? selectedItem = radioItem.initialRadioValue;

    return StatefulBuilder(
      key: _menu._key,
      builder: (_, setState) {
        onChanged(changed) {
          setState(() {
            selectedItem = changed;

            if (radioItem.onChanged != null) {
              radioItem.onChanged!(changed);
            }
          });
        }

        buildChild(e) {
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
                  visualDensity: VisualDensity(vertical: -4),
                  onChanged: onChanged,
                ),
              ),
            ),
          );
        }

        final children = radioItem.radioItems
            .map<Widget>(buildChild)
            .toList(growable: false);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
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

  void _addHoveredPopupKey(PlutoMenuItem menu, {bool addSelf = true}) {
    if (addSelf) _hoveredPopupKey.add(menu._key.toString());

    var current = menu._parent;
    while (current != null) {
      _hoveredPopupKey.add(current._key.toString());
      current = current._parent;
    }
  }

  void _showSubMenuDelay(PlutoMenuItem menu) {
    Future.delayed(const Duration(milliseconds: 30), () {
      showSubMenu(menu);
    });
  }

  void _removeHoveredPopupKey(PlutoMenuItem menu) {
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
  }

  @override
  Widget build(BuildContext context) {
    Widget menuWidget = InkWell(
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
            SizedBox(width: 5),
          ],
          Text(widget.menu.title, style: widget.textStyle),
        ],
      ),
    );

    if (widget.mode.isHover) {
      onHover(event) {
        _hoveredPopupKey.clear();

        if (!widget.menu._hasChildren) return;

        _addHoveredPopupKey(widget.menu, addSelf: false);

        _showSubMenuDelay(widget.menu);
      }

      onExit(event) => _removeHoveredPopupKey(widget.menu);

      menuWidget = MouseRegion(
        onHover: onHover,
        onExit: onExit,
        child: menuWidget,
      );
    }

    return Container(
      height: widget.height,
      padding: widget.padding,
      child: menuWidget,
    );
  }
}
