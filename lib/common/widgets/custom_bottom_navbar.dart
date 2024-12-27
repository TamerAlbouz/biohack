import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/state/navbar_state_base.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/colors.dart';

class CustomBottomNavBar<T extends Cubit<S>, S extends NavbarStateBase>
    extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, S>(
      builder: (context, state) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory, // Disables the splash effect
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: MyColors.primary,
            ),
            height: 78,
            child: BottomNavigationBar(
              currentIndex: state.index,
              items: items.map((item) {
                int itemIndex = items.indexOf(item);
                bool isActive = itemIndex == state.index;

                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isActive ? 50 : 40,
                      height: isActive ? 28 : 25,
                      // Enlarges when active
                      decoration: BoxDecoration(
                        color:
                            isActive ? MyColors.primaryLight : MyColors.primary,
                        borderRadius: kRadius20,
                      ),
                      child: isActive ? item.activeIcon : item.icon,
                    ),
                  ),
                  label: item.label,
                );
              }).toList(),
              onTap: (index) => onTap(index),
              iconSize: 24,
              enableFeedback: false,
              backgroundColor: MyColors.primary,
            ),
          ),
        );
      },
    );
  }
}
