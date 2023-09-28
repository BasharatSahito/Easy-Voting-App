import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class Alert {
  void dialog(context, DialogType dialogType, String heading, String okText, ok,
      String cancelText, cancel) {
    AwesomeDialog(
      context: context,
      padding: const EdgeInsets.all(30),
      dismissOnTouchOutside: false,
      dialogType: dialogType,
      animType: AnimType.scale,
      buttonsBorderRadius: const BorderRadius.all(Radius.circular(2)),
      title: heading,
      btnOkText: okText,
      btnOkOnPress: ok,
      btnCancelText: cancelText,
      btnCancelOnPress: cancel,
    ).show();
  }
}
