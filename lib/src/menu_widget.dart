part of pluto_menu_bar;

class _MenuWidget extends StatefulWidget {
  final PlutoMenuItem menu;

  final String goBackButtonText;

  final bool showBackButton;

  final double height;

  final Color backgroundColor;

  final PlutoMenuItemStyle style;

  final PlutoMenuBarMode mode;

  final GlobalKey<State<StatefulWidget>>? selectedMenuKey;

  final void Function(GlobalKey<State<StatefulWidget>>? key)?
      setSelectedMenuKey;

  _MenuWidget(
    this.menu, {
    required this.goBackButtonText,
    required this.showBackButton,
    required this.height,
    required this.backgroundColor,
    required this.style,
    required this.mode,
    this.selectedMenuKey,
    this.setSelectedMenuKey,
  }) : super(key: menu._key);

  @override
  State<_MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<_MenuWidget> {
  bool _disposed = false;

  SplayTreeMap<String, OverlayEntry> _popups = SplayTreeMap();

  Set<String> _hoveredPopupKey = {};

  bool get enabledSelectedTopMenu => widget.style.enableSelectedTopMenu;

  bool get isSelectedMenu =>
      enabledSelectedTopMenu && widget.selectedMenuKey == widget.menu.key;

  Color get iconColor {
    return isSelectedMenu
        ? widget.style.selectedTopMenuIconColor
        : widget.style.iconColor;
  }

  TextStyle get textStyle {
    return isSelectedMenu
        ? widget.style.selectedTopMenuTextStyle
        : widget.style.textStyle;
  }

  @override
  void dispose() {
    _disposed = true;

    _hoveredPopupKey.clear();
    _popups.forEach((k, v) => v.remove());
    _popups.clear();

    super.dispose();
  }

  void openMenu(PlutoMenuItem menu) async {
    if (widget.menu.onTap != null) {
      widget.menu.onTap!();
    }

    if (widget.menu.hasChildren) {
      showSubMenu(widget.menu);
    }
  }

  void showSubMenu(PlutoMenuItem menu) async {
    if (!menu.hasChildren) return;
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
    if (!menu._hasContext) return;

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
        Widget buildItemWidget(PlutoMenuItem item) {
          Widget menuItemWidget = _ItemWidget(
            menu: item,
            iconScale: widget.style.iconScale,
            unselectedColor: widget.style.unselectedColor,
            activatedColor: widget.style.activatedColor,
            indicatorColor: widget.style.indicatorColor,
            menuIconColor: widget.style.iconColor,
            moreIconColor: widget.style.moreIconColor,
            menuIconSize: widget.style.iconSize,
            textStyle: widget.style.textStyle,
          );

          if (item.type.isDivider) return menuItemWidget;

          EdgeInsets padding;
          if (item.type.isCheckbox || item.type.isRadio) {
            padding = EdgeInsets.symmetric(vertical: 10);
          } else {
            padding = EdgeInsets.symmetric(horizontal: 15, vertical: 10);
          }

          menuItemWidget = TextButton(
            onPressed: item.onTap,
            style: TextButton.styleFrom(
              textStyle: widget.style.textStyle,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Padding(padding: padding, child: menuItemWidget),
          );

          if (!item.hasChildren) return menuItemWidget;

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
    if (_disposed) return;
    if (!menu._hasContext) return;

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
        Widget menuItem = _ItemWidget(
          menu: menu,
          iconScale: widget.style.iconScale,
          unselectedColor: widget.style.unselectedColor,
          activatedColor: widget.style.activatedColor,
          indicatorColor: widget.style.indicatorColor,
          menuIconColor: widget.style.iconColor,
          moreIconColor: widget.style.moreIconColor,
          menuIconSize: widget.style.iconSize,
          textStyle: widget.style.textStyle,
        );

        double height = kMinInteractiveDimension;
        EdgeInsets? padding;
        if (menu.type.isDivider) {
          height = (menu as PlutoMenuItemDivider).height;
          padding = EdgeInsets.only(left: 0, right: 0);
        }

        return PopupMenuItem<PlutoMenuItem>(
          value: menu,
          child: menuItem,
          enabled: menu.enable,
          height: height,
          padding: padding,
        );
      }).toList(growable: false),
      elevation: 2.0,
      color: widget.backgroundColor,
      useRootNavigator: true,
    ).then((selectedMenu) async {
      if (selectedMenu == null) return;

      if (selectedMenu.hasChildren) {
        _showTappedPopupMenu(selectedMenu, context, selectedMenu.children!);
        return;
      }

      if (selectedMenu.onTap != null) {
        selectedMenu.onTap!();
      }
    });
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

  void _setSelectedMenuKey() {
    if (!enabledSelectedTopMenu) return;

    bool? resolved = true;

    if (widget.style.selectedTopMenuResolver != null) {
      resolved = widget.style.selectedTopMenuResolver!(
        widget.menu,
        widget.selectedMenuKey == null
            ? null
            : widget.menu.key == widget.selectedMenuKey,
      );
    }

    if (resolved == false) return;

    widget.setSelectedMenuKey!(resolved == null ? null : widget.menu.key);
  }

  @override
  Widget build(BuildContext context) {
    Widget menuWidget = InkWell(
      onTap: () async {
        _setSelectedMenuKey();

        openMenu(widget.menu);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.menu.icon != null) ...[
            Icon(
              widget.menu.icon,
              color: iconColor,
              size: widget.style.iconSize,
            ),
            SizedBox(width: 5),
          ],
          Text(widget.menu.title, style: textStyle),
        ],
      ),
    );

    if (widget.mode.isHover) {
      onHover(event) {
        _hoveredPopupKey.clear();

        if (!widget.menu.hasChildren) return;

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

    return SizedBox(
      height: widget.height,
      child: Padding(
        padding: widget.style.padding,
        child: menuWidget,
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  const _ItemWidget({
    required this.menu,
    required this.iconScale,
    required this.unselectedColor,
    required this.activatedColor,
    required this.indicatorColor,
    required this.menuIconColor,
    required this.moreIconColor,
    required this.menuIconSize,
    required this.textStyle,
  });

  final PlutoMenuItem menu;

  final double iconScale;

  final Color unselectedColor;

  final Color activatedColor;

  final Color indicatorColor;

  final Color menuIconColor;

  final Color moreIconColor;

  final double menuIconSize;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    switch (menu.type) {
      case PlutoMenuItemType.button:
        return ButtonItemWidget(
          menu: menu,
          menuIconColor: menuIconColor,
          moreIconColor: moreIconColor,
          menuIconSize: menuIconSize,
          textStyle: textStyle,
        );
      case PlutoMenuItemType.checkbox:
        return CheckboxItemWidget(
          menu: menu as PlutoMenuItemCheckbox,
          iconScale: iconScale,
          unselectedColor: unselectedColor,
          activatedColor: menuIconColor,
          indicatorColor: indicatorColor,
          moreIconColor: moreIconColor,
          textStyle: textStyle,
        );
      case PlutoMenuItemType.radio:
        return RadioItemWidget(
          menu: menu as PlutoMenuItemRadio,
          iconScale: iconScale,
          activatedColor: activatedColor,
          unselectedColor: unselectedColor,
          textStyle: textStyle,
        );
      case PlutoMenuItemType.widget:
        return (menu as PlutoMenuItemWidget).widget;
      case PlutoMenuItemType.divider:
        final dividerItem = menu as PlutoMenuItemDivider;
        return Divider(
          color: dividerItem.color,
          indent: dividerItem.indent,
          endIndent: dividerItem.endIndent,
          thickness: dividerItem.thickness,
        );
    }
  }
}
