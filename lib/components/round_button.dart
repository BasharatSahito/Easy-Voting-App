import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String btnTitle;
  final Icon? btnIcon;
  final FontWeight fntweight;
  final double fntSize;
  final Color? fontColor;
  final bool loader;

  const RoundButton({
    super.key,
    required this.btnTitle,
    required this.onTap,
    this.loader = false,
    this.btnIcon,
    this.fntweight = FontWeight.normal,
    this.fntSize = 18,
    this.fontColor = Colors.black,
  });

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

//  color: _isButtonPressed
//                   ? Color.fromARGB(255, 189, 193, 223)
//                   : Color(0xFFC5CAE9),

//  color: _isButtonPressed
//                       ? Colors.grey.shade200
//                       : Colors.grey.shade300
class _RoundButtonState extends State<RoundButton> {
  bool _isButtonPressed = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isButtonPressed = true),
          onTapUp: (_) => setState(() => _isButtonPressed = false),
          onTapCancel: () => setState(() => _isButtonPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _isButtonPressed
                      ? Colors.grey.shade200
                      : Colors.grey.shade300),
              boxShadow: _isButtonPressed
                  ? []
                  : [
                      //darker the shadow on bottom right
                      // BoxShadow(
                      //   color: Color.fromARGB(255, 125, 128, 146),
                      //   offset: const Offset(2, 2),
                      //   blurRadius: 7,
                      //   spreadRadius: 1,
                      // ),
                      // //darker the shadow on top left
                      // const BoxShadow(
                      //   color: Color.fromARGB(255, 221, 222, 245),
                      //   offset: Offset(-3, -3),
                      //   blurRadius: 7,
                      //   spreadRadius: 1,
                      // ),
                      BoxShadow(
                        color: Colors.grey.shade500,
                        offset: const Offset(2, 2),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                      //darker the shadow on top left
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-2, -2),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Center(
                child: widget.loader
                    ? CircularProgressIndicator(
                        color: Colors.grey[850]!,
                      )
                    : Text(
                        widget.btnTitle,
                        style: TextStyle(
                          color: widget.fontColor,
                          fontSize: widget.fntSize,
                          fontWeight: widget.fntweight,
                          fontFamily: 'Rubik Regular',
                        ),
                      )),
          ),
        ),
      ],
    );
  }
}
