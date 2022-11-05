import 'package:flutter/material.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

class RadioItemWidget extends StatefulWidget {
  const RadioItemWidget({
    required this.menu,
    required this.iconScale,
    required this.unselectedColor,
    required this.activatedColor,
    required this.textStyle,
    super.key,
  });

  final PlutoMenuItemRadio menu;

  final double iconScale;

  final Color activatedColor;

  final Color unselectedColor;

  final TextStyle textStyle;

  @override
  State<RadioItemWidget> createState() => _RadioItemWidgetState();
}

class _RadioItemWidgetState extends State<RadioItemWidget> {
  Object? _selectedItem;

  @override
  void initState() {
    super.initState();

    _selectedItem = widget.menu.initialRadioValue;
  }

  _onChanged(changed) {
    setState(() {
      _selectedItem = changed;

      if (widget.menu.onChanged != null) {
        widget.menu.onChanged!(changed);
      }
    });
  }

  Widget buildChild(e) {
    final String title =
        widget.menu.getTitle == null ? e.toString() : widget.menu.getTitle!(e);

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
            groupValue: _selectedItem,
            activeColor: widget.activatedColor,
            visualDensity: VisualDensity(vertical: -4),
            onChanged: _onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.menu.radioItems
          .map<Widget>(buildChild)
          .toList(growable: false),
    );
  }
}
