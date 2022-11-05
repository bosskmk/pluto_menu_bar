import 'package:flutter/material.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

class ButtonItemWidget extends StatelessWidget {
  const ButtonItemWidget({
    required this.menu,
    required this.menuIconColor,
    required this.moreIconColor,
    required this.menuIconSize,
    required this.textStyle,
    super.key,
  });

  final PlutoMenuItem menu;

  final Color menuIconColor;

  final Color moreIconColor;

  final double menuIconSize;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: menu.key,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (menu.icon != null) ...[
          Icon(
            menu.icon,
            color: menuIconColor,
            size: menuIconSize,
          ),
          SizedBox(width: 5),
        ],
        Expanded(
          child: Text(
            menu.title,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        if (menu.hasChildren && !menu.isBack)
          Icon(Icons.arrow_right, color: moreIconColor),
      ],
    );
  }
}
