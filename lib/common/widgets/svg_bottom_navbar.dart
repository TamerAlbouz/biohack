import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medtalk/common/state/navbar_state_base.dart';

class SvgBottomNavBar<T extends Cubit<S>, S extends NavbarStateBase>
    extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final Function(int) onTap;

  const SvgBottomNavBar({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            // Adjust this negative value to control how much it overflows
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/svgs/Cool-Waves-Nav.svg',
              fit: BoxFit.fitWidth,
              allowDrawingOutsideViewBox: true,
              clipBehavior: Clip.none,
              width: MediaQuery.of(context).size.width,
              placeholderBuilder: (context) => const SizedBox.shrink(),
            ),
          ),
          BlocBuilder<T, S>(
            builder: (context, state) {
              return Theme(
                data: Theme.of(context).copyWith(
                  splashFactory:
                      NoSplash.splashFactory, // Disables the splash effect
                ),
                child: BottomNavigationBar(
                  currentIndex: state.index,
                  items: items,
                  onTap: (index) => onTap(index),
                  iconSize: 24,
                  selectedIconTheme:
                      const IconThemeData(size: 30, color: Colors.white),
                  enableFeedback: false,
                  backgroundColor: Colors.transparent,
                  // Set the background to transparent
                ),
              );
            },
          ),
        ]);
  }
}
