import 'package:ble_app/services/bluetooth_status_checker.dart';
import 'package:ble_app/utilities/enums.dart';
import 'package:flutter/foundation.dart';

class BluetoothStatusProvider extends ChangeNotifier {
  /// singleton instance of [BluetoothStatusProvider]
  factory BluetoothStatusProvider() => _bluetoothStatusProvider;

  static final BluetoothStatusProvider _bluetoothStatusProvider =
      BluetoothStatusProvider._();

  BluetoothStatusProvider._() {
    bluetoothStatus = BluetoothConnectionStatus.off;
    updateBluetoothStatus();
  }

  late BluetoothConnectionStatus bluetoothStatus;

  /// function to update bluetooth status upon listening to status updates
  void updateBluetoothStatus() {
    BluetoothStatusChecker().onStatusChange.listen((status) {
      bluetoothStatus = status;
      notifyListeners();
    });
  }

  /// function to get current [bluetoothStatus]
  BluetoothConnectionStatus get bluetoothState => bluetoothStatus;
}
