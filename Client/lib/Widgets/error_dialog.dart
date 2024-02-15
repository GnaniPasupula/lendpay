import 'package:flutter/material.dart';

class ErrorDialogWidget {
  ErrorDialogWidget(BuildContext context, errorMessage);

  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Colors.green)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
        backgroundColor: Colors.yellow,
      ),
    );
  }
}
