part of pluto_menu_bar;

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

  /// {@macro pluto_menu_item_style}
  final PlutoMenuItemStyle itemStyle;

  /// Determines the mode in which the submenu is opened.
  ///
  /// [PlutoMenuBarMode.tap] Tap to open a submenu.
  /// [PlutoMenuBarMode.hover] Opens a submenu by hovering the mouse.
  final PlutoMenuBarMode mode;

  PlutoMenuBar({
    required this.menus,
    this.goBackButtonText = 'Go back',
    this.showBackButton = true,
    this.height = 45,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black12,
    this.itemStyle = const PlutoMenuItemStyle(),
    this.mode = PlutoMenuBarMode.tap,
  }) : assert(menus.length > 0);

  @override
  _PlutoMenuBarState createState() => _PlutoMenuBarState();
}

class _PlutoMenuBarState extends State<PlutoMenuBar> {
  GlobalKey<State<StatefulWidget>>? _selectedMenuKey;

  bool get enabledSelectedTopMenu => widget.itemStyle.enableSelectedTopMenu;

  @override
  void initState() {
    super.initState();

    _initSelectedTopMenu();
  }

  void _initSelectedTopMenu() {
    if (!enabledSelectedTopMenu) return;
    if (widget.itemStyle.initialSelectedTopMenuIndex == null) return;

    int index = widget.itemStyle.initialSelectedTopMenuIndex!;

    if (index < 0) {
      index = 0;
    } else if (index >= widget.menus.length) {
      index = widget.menus.length - 1;
    }

    _selectedMenuKey = widget.menus[index].key;
  }

  void _setSelectedMenuKey(GlobalKey<State<StatefulWidget>>? key) {
    if (!enabledSelectedTopMenu) return;

    setState(() {
      _selectedMenuKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, size) {
        return SizedBox(
          width: size.maxWidth,
          height: widget.height,
          child: DecoratedBox(
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
                    backgroundColor: widget.backgroundColor,
                    style: widget.itemStyle,
                    mode: widget.mode,
                    selectedMenuKey: _selectedMenuKey,
                    setSelectedMenuKey: _setSelectedMenuKey,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// {@template pluto_menu_item_style}
/// Set the style of the menu.
/// {@endtemplate}
class PlutoMenuItemStyle {
  const PlutoMenuItemStyle({
    this.iconColor = Colors.black54,
    this.iconSize = 20,
    this.moreIconColor = Colors.black54,
    this.iconScale = 0.86,
    this.unselectedColor = Colors.black26,
    this.activatedColor = Colors.lightBlue,
    this.indicatorColor = const Color(0xFFDCF5FF),
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    this.enableSelectedTopMenu = false,
    this.initialSelectedTopMenuIndex = 0,
    this.selectedTopMenuIconColor = Colors.lightBlue,
    this.selectedTopMenuTextStyle = const TextStyle(
      color: Colors.lightBlue,
      fontSize: 14,
    ),
    this.selectedTopMenuResolver,
  });

  final Color iconColor;

  final double iconSize;

  final Color moreIconColor;

  final double iconScale;

  final Color unselectedColor;

  final Color activatedColor;

  final Color indicatorColor;

  final EdgeInsets padding;

  final TextStyle textStyle;

  /// When the top menu is tapped, the selected style is set.
  final bool enableSelectedTopMenu;

  /// Initial top-level menu selection index.
  ///
  /// If the value is set to null, no menu is selected.
  ///
  /// Valid only when [enableSelectedTopMenu] is set to true.
  final int? initialSelectedTopMenuIndex;

  /// The color of the icon in the selected state of the top menu.
  ///
  /// Valid only when [enableSelectedTopMenu] is set to true.
  final Color selectedTopMenuIconColor;

  /// The text style of the selected state of the top-level menu.
  ///
  /// Valid only when [enableSelectedTopMenu] is set to true.
  final TextStyle selectedTopMenuTextStyle;

  /// Determines whether the top-level menu is enabled or disabled when tapped.
  ///
  /// Valid only when [enableSelectedTopMenu] is set to true.
  ///
  /// ```dart
  /// selectedTopMenuResolver: (menu, enabled) {
  ///   final description = enabled == true ? 'disabled' : 'enabled';
  ///   message(context, '${menu.title} $description');
  ///   return enabled == true ? null : true;
  /// },
  /// ```
  final bool? Function(PlutoMenuItem, bool?)? selectedTopMenuResolver;
}

enum PlutoMenuBarMode {
  hover,
  tap;

  bool get isHover => this == PlutoMenuBarMode.hover;
  bool get isTap => this == PlutoMenuBarMode.tap;
}
