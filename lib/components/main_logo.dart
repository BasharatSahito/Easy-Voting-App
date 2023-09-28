import 'package:flutter/material.dart';

class MainLogo extends StatelessWidget {
  const MainLogo({
    Key? key,
    required this.whiteLogo,
  }) : super(key: key);

  final bool whiteLogo;

  @override
  Widget build(BuildContext context) {
    return Image(
      // height: MediaQuery.of(context).size.height * .1,
      // width: MediaQuery.of(context).size.width * .9,
      image: whiteLogo
          ? const AssetImage(
              "assets/easy_voting_logo_white.png",
            )
          : const AssetImage(
              "assets/easy_voting_logo.png",
            ),
    );
  }
}
