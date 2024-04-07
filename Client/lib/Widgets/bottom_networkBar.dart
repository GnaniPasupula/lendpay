import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = (result != ConnectivityResult.none);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return const SizedBox();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      color: colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.signal_wifi_off,
                color: colorScheme.onError,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                "You are offline",
                style: TextStyle(color: colorScheme.onError),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
