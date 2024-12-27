import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medtalk/styles/sizes.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/svgs/Logo.svg',
          semanticsLabel: "Logo",
          width: 70,
          height: 70,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        kGap5,
        Padding(
          padding: kPaddH14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                  text: TextSpan(
                text: 'BioHack',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
