import 'package:flutter/material.dart';

class ErrorDialogWidget {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
        backgroundColor: Colors.yellow,
      ),
    );
  }
}
