## [3.0.1] - 2023. 1. 26

* Updated for flutter 3.7 version.

## [3.0.0] - 2022. 11. 30

* Add selected top menu.
* Modify menu item style.  
  Properties related to menu item styles have been moved to the itemStyle property.      
  ```dart
  PlutoMenuBar(
    backgroundColor: Colors.deepOrange,
    itemStyle: const PlutoMenuItemStyle(
      activatedColor: Colors.white,
      indicatorColor: Colors.deepOrange,
      textStyle: TextStyle(color: Colors.white),
      iconColor: Colors.white,
      moreIconColor: Colors.white,
    ),
    menus: orangeTapMenus,
  ),
  ```

## [2.0.2] - 2022. 11. 25

* Add PlutoMenuItemWidget.  
  https://pluto.weblaze.dev/plutomenuitemwidget

## [2.0.1] - 2022. 10. 15

* Fix submenu position bug.

## [2.0.0] - 2022. 10. 13

* Add hover-open mode.

## [1.1.4] - 2022. 9. 26

* Add showBackButton.

## [1.1.3] - 2022. 8. 7

* Add Divider.

## [1.1.2] - 2022. 7. 15

* Fix menu position.

## [1.1.1] - 2022. 7. 6

* Fix an error when the submenu was disposed.

## [1.1.0] - 2022. 7. 6

* Add checkbox, radio.

## [1.0.0] - 2022. 7. 6

* Update for flutter 2.5+

## [1.0.0-nullsafety.0] - 2021. 1. 16

* Null safety.

## [0.1.4] - 2020. 9. 30

* Add a menu icon.

## [0.1.3] - 2020. 9. 18

* Fix typo. (onTab > onTap) :) Thanks to Schwusch for reporting.

## [0.1.2] - 2020. 9. 18

* Fix a bug where the location of the sub-menu did not match.

## [0.1.1] - 2020. 9. 17

* Change the default style : Change the background, font, and border.

## [0.1.0] - 2020. 9. 15

* Multiple sub-menu : Add as many submenus as you like.
