import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/radio/rounded_radio_button.dart';

import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class AmPmSplitRadioGroup extends StatefulWidget {
  final List<String> amOptions;
  final List<String> pmOptions;
  final void Function(bool)? onSelected;
  final BoxDecoration? decoration;
  final Color? selectedColor;
  final Color? unselectedColor;
  final EdgeInsets? contentPadding;
  final Color? unselectedTextColor;
  final TextStyle? textStyle;
  final void Function(String, int) onChanged;
  final int? selectedIndex;

  const AmPmSplitRadioGroup({
    super.key,
    required this.amOptions,
    required this.pmOptions,
    this.onSelected,
    this.decoration,
    this.selectedColor,
    this.unselectedColor,
    this.contentPadding,
    this.unselectedTextColor,
    this.textStyle,
    this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<AmPmSplitRadioGroup> createState() => _AmPmSplitRadioGroupState();
}

class _AmPmSplitRadioGroupState extends State<AmPmSplitRadioGroup> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  Widget _buildRadioButtonsWrapper(List<String> options, int startIndex) {
    return Wrap(
      runSpacing: 8.0,
      children: _buildRadioButtons(options, startIndex),
    );
  }

  List<Widget> _buildRadioButtons(List<String> options, int startIndex) {
    return [
      for (int i = 0; i < options.length; i++)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: RoundedRadioButton(
            label: options[i],
            isSelected: _selectedIndex == (startIndex + i),
            decoration: widget.decoration,
            selectedColor: widget.selectedColor,
            unselectedColor: widget.unselectedColor,
            contentPadding: widget.contentPadding,
            unselectedTextColor: widget.unselectedTextColor,
            textStyle: widget.textStyle,
            onSelected: () {
              setState(() {
                if (widget.onSelected != null) {
                  widget.onSelected!(true);
                }
                _selectedIndex = startIndex + i;

                // get the 24 hour format
                // Convert to 24-hour format
                String convertTo24HourFormat(String time, {bool isAm = true}) {
                  // Split the time into hours and minutes
                  List<String> parts = time.split(':');
                  int hours = int.parse(parts[0]);
                  String minutes = parts[1];

                  // Determine if it's PM and adjust hours accordingly
                  if (!isAm && hours != 12) {
                    hours += 12;
                  } else if (isAm && hours == 12) {
                    hours = 0;
                  }

                  // Remove AM/PM and pad with zero if needed
                  return '${hours.toString().padLeft(2, '0')}:$minutes';
                }

                // check if it's AM or PM by looking at the startIndex
                final isAm = startIndex == 0;

                String twentyFourHourTime =
                    convertTo24HourFormat(options[i], isAm: isAm);

                widget.onChanged(twentyFourHourTime, _selectedIndex!);
              });
            },
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.amOptions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SizedBox(
                      width: 25,
                      child: FaIcon(FontAwesomeIcons.solidSun,
                          color: Colors.orangeAccent, size: 22),
                    ),
                    kGap8,
                    Text('Morning (AM)',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: Font.family,
                            fontSize: Font.medium)),
                  ],
                ),
                kGap10,
                _buildRadioButtonsWrapper(widget.amOptions, 0),
                kGap28
              ],
            ),
          if (widget.pmOptions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SizedBox(
                      width: 25,
                      child: FaIcon(FontAwesomeIcons.solidMoon,
                          color: Colors.blueAccent, size: 22),
                    ),
                    kGap8,
                    Text('Evening (PM)',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: Font.family,
                            fontSize: Font.medium)),
                  ],
                ),
                kGap10,
                _buildRadioButtonsWrapper(
                    widget.pmOptions, widget.amOptions.length),
              ],
            ),
        ],
      ),
    );
  }
}
