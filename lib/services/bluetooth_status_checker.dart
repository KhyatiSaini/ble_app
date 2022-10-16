import 'dart:async';

import 'package:ble_app/utilities/enum.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStatusChecker {
  /// singleton instance of [BluetoothStatusChecker]
  factory BluetoothStatusChecker() => _bluetoothStatusChecker;

  static final BluetoothStatusChecker _bluetoothStatusChecker =
      BluetoothStatusChecker._();

  BluetoothStatusChecker._() {
    /// call the [_sendStatusUpdates] function when stream is subscribed by a listener
    _statusController.onListen = () {
      _sendStatusUpdates();
    };

    /// when stream is cancelled, stop the status update function recurring calls by cancelling the timer
    _statusController.onCancel = () {
      _timer?.cancel();
      _lastStatus = null;
    };
  }

  BluetoothConnectionStatus? _lastStatus;
  Timer? _timer;

  final StreamController<BluetoothConnectionStatus> _statusController =
      StreamController.broadcast();

  static const Duration checkInterval = Duration(
    seconds: 5,
  );

  /// function to get [BluetoothConnectionStatus]
  Future<BluetoothConnectionStatus> get connectionStatus async {
    final FlutterBluePlus flutterBluePlus = FlutterBluePlus.instance;
    final bool status = await flutterBluePlus.isOn;
    return status
        ? BluetoothConnectionStatus.on
        : BluetoothConnectionStatus.off;
  }

  Future _sendStatusUpdates([Timer? timer]) async {
    _timer?.cancel();
    timer?.cancel();

    final BluetoothConnectionStatus currentStatus = await connectionStatus;

    /// if [_currentStatus] is different from [_lastStatus] and [StreamController] has listener then adding new value to the stream
    if (currentStatus != _lastStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    /// if [_statusController] does not have any listeners then return from the function
    if (!_statusController.hasListener) {
      return;
    }

    /// adding a callback
    _timer = Timer(checkInterval, _sendStatusUpdates);

    /// updating last known status to current one
    _lastStatus = currentStatus;
  }

  /// function to return Stream of [BluetoothConnectionStatus]
  Stream<BluetoothConnectionStatus> get onStatusChange =>
      _statusController.stream;

  /// function to check whether [BluetoothConnectionStatus] stream has listeners
  bool get hasListeners => _statusController.hasListener;
}
