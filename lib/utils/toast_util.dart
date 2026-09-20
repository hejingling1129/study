import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app_theme.dart';

void showSuccessToast(String msg) {
  Fluttertoast.showToast(
    msg: '✓ $msg',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    backgroundColor: AppTheme.primary,
    textColor: Colors.white,
    fontSize: 14,
  );
}

void showErrorToast([String? msg]) {
  Fluttertoast.showToast(
    msg: msg ?? '操作失败，请稍后重试',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    backgroundColor: AppTheme.error,
    textColor: Colors.white,
    fontSize: 14,
  );
}
