import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../styles/colors.dart';

class CustomComplexDropDown extends StatefulWidget {
  /// A list of strings representing the dropdown items.
  ///
  /// Example:
  /// ```dart
  /// items: ['Item 1', 'Item 2', 'Item 3']
  /// ```
  final List<String> items;

  /// The initial selected value.
  /// If null, the dropdown shows the [defaultOption].
  ///
  /// Example:
  /// ```dart
  /// initialValue: 'Item 1'
  /// ```
  final String? initialValue;

  /// Placeholder text shown when no item is selected.
  /// Defaults to "Select an item".
  ///
  /// Example:
  /// ```dart
  /// hint: 'Select an item'
  /// ```
  final String defaultOption;

  /// The title of the dropdown.
  ///
  /// Example:
  /// ```dart
  /// title: 'Specialty'
  /// ```
  final String title;

  /// The icon to display before the title.
  /// Defaults to null.
  ///
  /// Example:
  /// ```dart
  /// icon: FaIcon(FontAwesomeIcons.stethoscope)
  /// ```
  final FaIcon? icon;

  /// Callback function invoked when a new item is selected.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (value) {
  ///  print(value);
  /// }
  /// ```
  final void Function(String?) onChanged;

  /// Width of the dropdown container.
  /// Defaults to the intrinsic width of the content.
  ///
  /// Example:
  /// ```dart
  /// width: 200
  /// ```
  final double? width;

  /// Background color of the dropdown container.
  /// Defaults to the theme's card color.
  ///
  /// Example:
  /// ```dart
  /// backgroundColor: Colors.grey[200]
  /// ```
  final Color? backgroundColor;

  /// Text color of the dropdown items and hint text.
  /// Defaults to the theme's text color.
  ///
  /// Example:
  /// ```dart
  /// textColor: Colors.black
  /// ```
  final Color? textColor;

  /// Background color of the dropdown menu.
  /// Defaults to the theme's dropdown color.
  ///
  /// Example:
  /// ```dart
  /// dropdownColor: Colors.white
  /// ```
  final Color? dropdownColor;

  /// Padding inside the dropdown container.
  /// Defaults to 12 pixels horizontally.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(8)
  /// ```
  final EdgeInsetsGeometry? padding;

  /// Rounds the corners of the dropdown container.
  /// Defaults to a radius of 8 pixels.
  ///
  /// Example:
  /// ```dart
  /// borderRadius: BorderRadius.circular(10)
  /// ```
  final BorderRadius? borderRadius;

  /// Search field color
  ///
  /// Example:
  /// ```dart
  /// searchFieldColor: Colors.grey[200]
  /// ```
  final Color? searchFieldColor;

  /// Max height of the dropdown menu.
  /// Defaults to 200 pixels.
  ///
  /// Example:
  /// ```dart
  /// maxMenuHeight: 300
  /// ```
  final double maxMenuHeight;

  /// A customizable dropdown widget with support for styling options and an initial value.
  ///
  /// [CustomComplexDropDown] provides a more complex designed dropdown menu where users can
  /// select an item from a list. The dropdown can be customized with various styling properties,
  /// such as colors, padding, border radius, and more. It also includes a hint text for when
  /// no selection is made.
  ///
  /// Example usage:
  /// ```dart
  /// CustomComplexDropDown(
  ///   items: ['Item 1', 'Item 2', 'Item 3'],
  ///   initialValue: 'Item 1',
  ///   onChanged: (value) {
  ///     print(value);
  ///   },
  ///   title: 'Specialty',
  ///   icon: FaIcon(FontAwesomeIcons.stethoscope),
  ///   hint: 'Select an item',
  ///   width: 200,
  ///   backgroundColor: Colors.grey[200],
  ///   textColor: Colors.black,
  ///   dropdownColor: Colors.white,
  ///   padding: EdgeInsets.all(8),
  ///   borderRadius: BorderRadius.circular(10),
  ///   searchFieldColor: Colors.grey[200],
  ///   maxMenuHeight: 300,
  /// )
  /// ```
  ///
  /// ### Properties:
  ///
  /// * [items] (required): A list of strings representing the dropdown items.
  /// * [initialValue]: The initial selected value. If null, the dropdown shows the [defaultOption].
  /// * [hint]: Placeholder text shown when no item is selected. Defaults to "Select an item".
  /// * [title]: The title of the dropdown.
  /// * [icon]: The icon to display before the title. Defaults to null.
  /// * [onChanged] (required): Callback function invoked when a new item is selected.
  /// * [width]: Width of the dropdown container. Defaults to the intrinsic width of the content.
  /// * [backgroundColor]: Background color of the dropdown container. Defaults to the theme's card color.
  /// * [textColor]: Text color of the dropdown items and hint text. Defaults to the theme's text color.
  /// * [dropdownColor]: Background color of the dropdown menu. Defaults to the theme's dropdown color.
  /// * [padding]: Padding inside the dropdown container. Defaults to 12 pixels horizontally.
  /// * [borderRadius]: Rounds the corners of the dropdown container. Defaults to a radius of 8 pixels.
  /// * [searchFieldColor]: Search field color
  /// * [maxMenuHeight]: Max height of the dropdown menu. Defaults to 200 pixels.
  const CustomComplexDropDown({
    super.key,
    required this.items,
    required this.title,
    required this.onChanged,
    this.initialValue,
    this.defaultOption = 'Select an item',
    this.width,
    this.backgroundColor = MyColors.textField,
    this.textColor,
    this.dropdownColor = MyColors.dropdown,
    this.padding,
    this.borderRadius,
    this.icon,
    this.searchFieldColor,
    this.maxMenuHeight = 200,
  });

  @override
  State<CustomComplexDropDown> createState() => _CustomComplexDropDownState();
}

class _CustomComplexDropDownState extends State<CustomComplexDropDown>
    with SingleTickerProviderStateMixin {
  String? selectedValue;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  late OverlayEntry _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  // filtered Items
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    filteredItems = widget.items; // Initialize with all items

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _toggleDropdown();
      }
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.items
          .where(
              (element) => element.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    // Force rebuild of overlay
    if (_isOpen) {
      _overlayEntry.markNeedsBuild();
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _animationController.reverse().then((value) {
        if (_overlayEntry.mounted) {
          _overlayEntry.remove();
        }
        setState(() {
          _isOpen = false;
          // Reset filtered items when closing
          filteredItems = widget.items;
        });
        _focusNode.unfocus();
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      setState(() {
        _isOpen = true;
      });
      _animationController.forward();
      _focusNode.requestFocus();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            shadowColor: Colors.black26,
            borderRadius: kRadius10,
            color: widget.dropdownColor,
            child: StatefulBuilder(
              // Add StatefulBuilder here
              builder: (context, setStateOverlay) {
                return AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return ClipRect(
                      child: Align(
                        heightFactor: _expandAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          color: widget.searchFieldColor ??
                              MyColors.dropDownSearchField,
                        ),
                        child: Focus(
                          focusNode: _focusNode,
                          child: TextField(
                            style: kTextFieldDropdown,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: kTextFieldDropdown,
                              prefixIcon: Icon(
                                Icons.search,
                                color: MyColors.textWhite,
                              ),
                              border: InputBorder.none,
                              contentPadding: kPaddH16V12,
                            ),
                            cursorColor: MyColors.textWhite,
                            onChanged:
                                _filterItems, // Use the new filter method
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: kRadius10,
                          color: widget.dropdownColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = widget.defaultOption;
                                });
                                widget.onChanged(widget.defaultOption);
                                _toggleDropdown();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  widget.defaultOption,
                                  style: kButtonHint.copyWith(
                                      color: MyColors.text),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints:
                            BoxConstraints(maxHeight: widget.maxMenuHeight),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: filteredItems
                              .where((item) => item != widget.defaultOption)
                              .map((String item) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                  milliseconds:
                                      200 + filteredItems.indexOf(item) * 40),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, -20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedValue = item;
                                  });
                                  widget.onChanged(item);
                                  _toggleDropdown();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    item,
                                    style: kButtonHint.copyWith(
                                        color: MyColors.text),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Focus(
          focusNode: _focusNode,
          child: Container(
            width: widget.width,
            padding: widget.padding ?? kPaddH20V10,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius ?? kRadius10,
              border: Border.all(color: MyColors.blue, width: 2.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: widget.icon,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          textAlign: TextAlign.start, style: kButtonHint),
                      Text(
                        selectedValue ?? widget.defaultOption,
                        style: kDropdownText,
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: MyColors.blue,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isOpen) {
      _overlayEntry.remove();
    }
    _focusNode.dispose();
    super.dispose();
  }
}
