import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medtalk/navigation/cubit/navigation_patient_cubit.dart';
import 'package:medtalk/styles/sizes.dart';

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
    return Stack(children: [
      Positioned(
        child: SvgPicture.asset(
          'assets/svgs/Cool-Waves-Nav.svg',
          fit: BoxFit.cover,
        ),
      ),
      BlocBuilder<T, S>(
        builder: (context, state) {
          return Container(
            padding: kPadd0,
            alignment: Alignment.bottomCenter,
            height: 95,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory:
                    NoSplash.splashFactory, // Disables the splash effect
              ),
              child: BottomNavigationBar(
                currentIndex: state.index,
                items: items,
                onTap: (index) => onTap(index),
                iconSize: 32,
              ),
            ),
          );
        },
      ),
    ]);
  }
}
