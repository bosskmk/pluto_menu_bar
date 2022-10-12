// ignore_for_file: unused_element
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
                  iconScale: widget.iconScale,
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
