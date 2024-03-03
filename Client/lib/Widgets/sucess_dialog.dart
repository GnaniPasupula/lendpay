import 'package:flutter/material.dart';

class SucessDialogWidget {
  SucessDialogWidget(BuildContext context, errorMessage);

  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Colors.green)),
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface, 
      ),
    );
  }
}
