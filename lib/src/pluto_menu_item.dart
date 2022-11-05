part of pluto_menu_bar;

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
  })  : _key = GlobalKey(),
        _isBack = false {
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
    this.children,
  })  : icon = null,
        enable = true,
        onTap = null,
        _key = GlobalKey(),
        _isBack = true;

  final GlobalKey _key;

  final bool _isBack;

  PlutoMenuItem? _parent;

  GlobalKey get key => _key;

  PlutoMenuItemType get type => PlutoMenuItemType.button;

  bool get isBack => _isBack;

  bool get hasChildren => children != null && children!.length > 0;

  bool get _isRootSubMenu => _parent == null;

  bool get _hasContext => _key.currentContext != null;

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

  void _setParent() {
    if (!hasChildren) return;
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

enum PlutoMenuItemType {
  button,
  checkbox,
  radio,
  divider;

  bool get isButton => this == PlutoMenuItemType.button;
  bool get isCheckbox => this == PlutoMenuItemType.checkbox;
  bool get isRadio => this == PlutoMenuItemType.radio;
  bool get isDivider => this == PlutoMenuItemType.divider;
}
