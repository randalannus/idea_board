import 'dart:async';

import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/ui/widgets/transition_switcher.dart';

class NetworkConnectivitySwitcher extends StatefulWidget {
  final Widget connectedChild;
  final Widget notConnectedChild;

  const NetworkConnectivitySwitcher({
    required this.connectedChild,
    required this.notConnectedChild,
    Key? key,
  }) : super(key: key);

  @override
  State<NetworkConnectivitySwitcher> createState() =>
      _NetworkConnectivitySwitcherState();
}

class _NetworkConnectivitySwitcherState
    extends State<NetworkConnectivitySwitcher> {
  static const bufferDuration = Duration(seconds: 1);

  final StreamController<bool> _isConnectedController = StreamController();
  late final Stream<bool> _isConnectedStream =
      _isConnectedController.stream.distinct();
  Timer? _timer;

  late final StreamSubscription<bool> _connectivitySubscription;

  @override
  void initState() {
    Connectivity().checkConnectivity().then(
          (result) => _connectionListener(result != ConnectivityResult.none),
        );
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .map<bool>((result) => result != ConnectivityResult.none)
        .distinct()
        .listen(_connectionListener);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySubscription.cancel();
    _isConnectedController.close();
    super.dispose();
  }

  void _connectionListener(bool isConnected) {
    _timer?.cancel();
    if (isConnected) {
      _isConnectedController.add(isConnected);
    } else {
      // "Not connected" events are delayed to avoid false alarms when switching
      // from cellular data to wifi.
      // If a "connected" event comes before the timer is finished then the
      // timer is cancelled.
      _timer =
          Timer(bufferDuration, () => _isConnectedController.add(isConnected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isConnectedStream,
      initialData: true,
      builder: (context, snapshot) {
        bool isConnected = snapshot.data ?? true;
        return MyPageTransitionSwitcher(
          transitionType: SharedAxisTransitionType.scaled,
          child: isConnected ? widget.connectedChild : widget.notConnectedChild,
        );
      },
    );
  }
}
