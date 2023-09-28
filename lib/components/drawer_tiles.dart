import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DrawerTiles extends StatefulWidget {
  final VoidCallback? onTap;
  final String btnTitle;
  final Icon btnIcon;
  final Icon endIcon;
  final EdgeInsets pads;

  const DrawerTiles({
    super.key,
    required this.btnTitle,
    required this.onTap,
    required this.btnIcon,
    this.endIcon = const Icon(null),
    this.pads = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<DrawerTiles> createState() => _DrawerTilesState();
}

class _DrawerTilesState extends State<DrawerTiles> {
  bool _isButtonPressed = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTapDown: (_) => setState(() => _isButtonPressed = true),
        onTapUp: (_) => setState(() => _isButtonPressed = false),
        onTapCancel: () => setState(() => _isButtonPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            // borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _isButtonPressed
                    ? Colors.grey.shade200
                    : Colors.grey.shade300),
            boxShadow: _isButtonPressed
                ? []
                : [
                    //darker the shadow on bottom right
                    BoxShadow(
                      color: Colors.grey.shade500,
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      // spreadRadius: 1,
                    ),
                    //darker the shadow on top left
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(0, -2),
                      blurRadius: 1,
                      // spreadRadius: 1,
                    ),
                  ],
          ),
          child: ListTile(
            contentPadding: widget.pads,
            leading: widget.btnIcon,
            title: Text(widget.btnTitle),
            trailing: widget.endIcon,
          ),
        ),
      )
    ]);
  }
}
              // child: Row(
              //   children: [
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     widget.btnIcon,
              //     const SizedBox(
              //       width: 25,
              //     ),
              //     Text(
              //       widget.btnTitle,
              //       style: const TextStyle(
              //           fontSize: 17,
              //           fontWeight: FontWeight.normal,
              //           fontFamily: "rubik regular"),
              //     ),
              //     Icon(Icons.arrow_forward_ios)
              //   ],
              // )),
        // OutlinedButton(
        //   style: OutlinedButton.styleFrom(
        //     minimumSize: const Size.fromHeight(50),
        //     side: BorderSide(width: 2, color: Colors.blue),
        //   ),
        //   onPressed: onTap,
        //   child: loader
        //       ? const CircularProgressIndicator(
        //           color: Colors.white,
        //           strokeWidth: 3.0,
        //         )
        //       : Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             if (btnIcon == null)
        //               Text(
        //                 btnTitle,
        //                 style: const TextStyle(fontSize: 17),
        //               ),
        //             if (btnIcon != null)
        //               Row(
        //                 children: [
        //                   Text(
        //                     btnTitle,
        //                     style: const TextStyle(fontSize: 17),
        //                   ),
        //                   const SizedBox(
        //                     width: 9,
        //                   ),
        //                   if (btnIcon != null) btnIcon!
        //                 ],
        //               ),
        //           ],
        //         ),
        // ),
