part of pluto_menu_bar;

class PlutoMenuItem {
  /// {@template pluto_menu_item_id}
  /// Set a unique ID for the menu widget.
  ///
  /// Prevents [key] from being changed when [PlutoMenuItem] is created in the [build] method.
  ///
  /// When [PlutoMenuItem] is created in [State.initState], etc.,
  /// there is no need to set [id] because [key] does not change
  /// even if [build] is called multiple times.
  /// {@endtemplate}
  Object? id;

  /// Menu title
  final String title;

  final IconData? icon;

  final bool enable;

  /// Callback executed when a menu is tapped
  final Function()? onTap;

  /// Passing [PlutoMenuItem] to a [List] creates a sub-menu.
  final List<PlutoMenuItem>? children;

  /// Button type menu item.
  PlutoMenuItem({
    /// {@macro pluto_menu_item_id}
    this.id,
    required this.title,
    this.icon,
    this.enable = true,
    this.onTap,
    this.children,
  })  : _key = id == null ? GlobalKey() : GlobalObjectKey(id),
        _isBack = false {
    _setParent();
  }

  /// A menu item of type checkbox.
  ///
  /// [id]
  /// {@macro pluto_menu_item_id}
  factory PlutoMenuItem.checkbox({
    Object? id,
    required String title,
    IconData? icon,
    bool enable = false,
    void Function()? onTap,
    List<PlutoMenuItem>? children,
    void Function(bool?)? onChanged,
    bool? initialCheckValue,
  }) {
    return PlutoMenuItemCheckbox(
      id: id,
      title: title,
      icon: icon,
      enable: enable,
      onTap: onTap,
      children: children,
      onChanged: onChanged,
      initialCheckValue: initialCheckValue,
    );
  }

  /// A menu item of type radio button.
  ///
  /// [id]
  /// {@macro pluto_menu_item_id}
  factory PlutoMenuItem.radio({
    Object? id,
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
      id: id,
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

  /// A menu item of type Widget.
  ///
  /// [id]
  /// {@macro pluto_menu_item_id}
  factory PlutoMenuItem.widget({
    Object? id,
    required Widget widget,
    bool enable = false,
    void Function()? onTap,
  }) {
    return PlutoMenuItemWidget(
      id: id,
      widget: widget,
      enable: enable,
      onTap: onTap,
    );
  }

  /// A menu item of type Divider.
  factory PlutoMenuItem.divider({
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
    super.id,
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
    super.id,
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

class PlutoMenuItemWidget extends PlutoMenuItem {
  PlutoMenuItemWidget({
    super.id,
    required this.widget,
    super.enable = false,
    super.onTap,
  }) : super(title: '_widget');

  PlutoMenuItemType get type => PlutoMenuItemType.widget;

  final Widget widget;
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
  widget,
  divider;

  bool get isButton => this == PlutoMenuItemType.button;
  bool get isCheckbox => this == PlutoMenuItemType.checkbox;
  bool get isRadio => this == PlutoMenuItemType.radio;
  bool get isWidget => this == PlutoMenuItemType.widget;
  bool get isDivider => this == PlutoMenuItemType.divider;
}
