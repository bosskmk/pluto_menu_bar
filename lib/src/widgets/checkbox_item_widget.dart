import 'package:flutter/material.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

class CheckboxItemWidget extends StatelessWidget {
  const CheckboxItemWidget({
    required this.menu,
    required this.iconScale,
    required this.unselectedColor,
    required this.activatedColor,
    required this.indicatorColor,
    required this.moreIconColor,
    required this.textStyle,
    super.key,
  });

  final PlutoMenuItemCheckbox menu;

  final double iconScale;

  final Color unselectedColor;

  final Color activatedColor;

  final Color indicatorColor;

  final Color moreIconColor;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: menu.key,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.scale(
          scale: iconScale,
          child: Theme(
            data: ThemeData(
              unselectedWidgetColor: unselectedColor,
            ),
            child: _Checkbox(
              menu: menu,
              activatedColor: activatedColor,
              indicatorColor: indicatorColor,
            ),
          ),
        ),
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

class _Checkbox extends StatefulWidget {
  const _Checkbox({
    required this.menu,
    required this.activatedColor,
    required this.indicatorColor,
  });

  final PlutoMenuItemCheckbox menu;

  final Color activatedColor;

  final Color indicatorColor;

  @override
  State<_Checkbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<_Checkbox> {
  bool? _checked;

  initState() {
    super.initState();

    _checked = widget.menu.initialCheckValue;
  }

  _onChanged(flag) {
    updateCheckBox() {
      _checked = flag;
      if (widget.menu.onChanged == null) return;
      widget.menu.onChanged!(flag);
    }

    setState(updateCheckBox);
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _checked,
      activeColor: widget.activatedColor,
      checkColor: widget.indicatorColor,
      visualDensity: VisualDensity(vertical: -4),
      onChanged: _onChanged,
    );
  }
}
