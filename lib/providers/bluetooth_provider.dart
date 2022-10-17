import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {
  /// singleton instance of [BluetoothProvider]
  factory BluetoothProvider() => _bluetoothProvider;

  static final BluetoothProvider _bluetoothProvider = BluetoothProvider._();

  BluetoothProvider._() {
    _flutterBluePlus = FlutterBluePlus.instance;
    _detectedDevices = [];
  }

  /// instance of [FlutterBluePlus]
  late FlutterBluePlus _flutterBluePlus;

  /// list of nearby and scanned [BluetoothDevices]
  late List<BluetoothDevice> _detectedDevices;

  /// list of nearby [BluetoothDevices]
  late List<BluetoothDevice> _nearbyDevices;

  /// list of all bluetooth services advertised by connected devices
  late List<BluetoothService> _services;

  /// connected [BluetoothDevice]
  BluetoothDevice? _connectedDevice;

  // GATT Profile for BLE communication
  static const brainServiceUUID = 'ca30c812-3ed5-44ea-961e-196a8c601de7';
  static const characteristicErrorUUID = '1db9a7de-135f-4509-b226-bd19d42126fd';

  /// [BluetoothService] and [BluetoothCharacteristic] for BLE communication
  BluetoothService? brainService;
  BluetoothCharacteristic? errorCharacteristic;

  /// function that returns status of Bluetooth
  Future<bool> bluetoothStatus() async {
    bool status = await _flutterBluePlus.isOn;
    return status;
  }

  /// function to start scan and populate [_detectedDevices] list if bluetooth is active
  Future startScan() async {
    bool status = await bluetoothStatus();
    await stopScan();
    if (status) {
      _nearbyDevices = [];
      scanAndPopulateList();
    }
  }

  /// function to populate scanned devices to the list
  void scanAndPopulateList() {
    _flutterBluePlus.connectedDevices.asStream().listen(addConnectedDevice);
    _flutterBluePlus.scanResults.listen(addScannedDevice);

    _detectedDevices = _nearbyDevices;
    _flutterBluePlus.startScan();
  }

  /// callback function to add [connectedDevices] to [_detectedDevices]
  void addConnectedDevice(List<BluetoothDevice> devices) {
    for (final BluetoothDevice bluetoothDevice in devices) {
      addDeviceToList(bluetoothDevice);
    }
  }

  /// callback function to add [scannedDevices] to [_detectedDevices]
  void addScannedDevice(List<ScanResult> scanResults) {
    for (final ScanResult scanResult in scanResults) {
      addDeviceToList(scanResult.device);
    }
  }

  /// function to add distinct [BluetoothDevice] to [_detectedDevices]
  void addDeviceToList(BluetoothDevice bluetoothDevice) {
    if (!_nearbyDevices.contains(bluetoothDevice)) {
      _nearbyDevices.add(bluetoothDevice);
      debugPrint(bluetoothDevice.toString());
      notifyListeners();
    }
  }

  /// function to connect to [selectedBluetoothDevice]
  Future<bool> connectToDevice(BluetoothDevice selectedBluetoothDevice) async {
    Future<bool>? returnValue;
    String deviceDisplayName;

    if (selectedBluetoothDevice.name.trim().isNotEmpty) {
      deviceDisplayName = selectedBluetoothDevice.name.trim();
    } else {
      deviceDisplayName = selectedBluetoothDevice.id.toString();
    }

    try {
      await selectedBluetoothDevice
          .connect(
        autoConnect: true,
      )
          .timeout(
              const Duration(
                seconds: 30,
              ), onTimeout: () {
        debugPrint('timeout occurred');
        returnValue = Future.value(false);
        disconnectDevice();
      }).then((value) {
        if (returnValue == null) {
          debugPrint('connection successful, connected to $deviceDisplayName');

          _connectedDevice = selectedBluetoothDevice;
          discoverServices();
          notifyListeners();
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'already connected') {
        debugPrint('already connected to the device $deviceDisplayName');
        _connectedDevice = selectedBluetoothDevice;
        discoverServices();
        notifyListeners();
      } else {
        rethrow;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return _connectedDevice == null ? false : true;
  }

  /// function to discover services of the [_connectedDevice]
  Future<void> discoverServices() async {
    if (_connectedDevice != null) {
      _services = await _connectedDevice!.discoverServices();

      // todo: based on the discovery of brain service and error characteristic, notify the status of communication compatibility
      bool discoverSuccessful = discoverBrainNodes();
    }
  }

  /// discover the brain service and error characteristic
  bool discoverBrainNodes() {
    for (BluetoothService bluetoothService in _services) {
      if (bluetoothService.uuid.toString() == brainServiceUUID) {
        brainService = bluetoothService;
        break;
      }
    }

    // if brain service is found with the connected device, assign characteristic
    if (brainService != null) {
      for (BluetoothCharacteristic characteristic
          in brainService!.characteristics) {
        if (characteristic.uuid.toString() == characteristicErrorUUID) {
          errorCharacteristic = characteristic;
          break;
        }
      }
    }

    if (brainService == null || errorCharacteristic == null) {
      return false;
    }

    return true;
  }

  /// function to read data of a particular [characteristic]
  Future<List<int>> readCharacteristics(
      BluetoothCharacteristic characteristic) async {
    final List<int> readValue =
        await characteristic.read().onError((error, stackTrace) {
      debugPrint('error while read ${error.toString()}');
      return [];
    });

    if (readValue.isNotEmpty) {
      debugPrint(readValue.toString());
      return readValue;
    }

    return [];
  }

  /// function to write data to a [characteristic]
  Future writeCharacteristics(
      BluetoothCharacteristic characteristic, List<int> value) async {
    final String? response = await characteristic
        .write(
      value,
      withoutResponse: false,
    )
        .onError((error, stackTrace) {
      debugPrint('error is ${error.toString()}');
    });

    if (response != null) {
      debugPrint(
          'response after writing the characteristic ${characteristic.uuid.toString()} is $response');
    }
  }

  /// function to listen to the characteristic value updates
  Future<List<int>> notify(BluetoothCharacteristic characteristic) async {
    List<int> response = [];
    await characteristic.setNotifyValue(true).onError((error, stackTrace) {
      debugPrint('error is ${error.toString()}');
      return false;
    });

    characteristic.value.listen((event) {
      debugPrint(
          '${characteristic.uuid.toString()} value: ${event.toString()}');

      response = event;
    });

    return response;
  }

  /// function to stop the scan
  Future stopScan() async {
    await _flutterBluePlus.stopScan();
  }

  /// function to disconnected [_connectedDevice]
  void disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
    }

    notifyListeners();
  }

  /// function to return a copy of [_detectedDevices]
  List<BluetoothDevice> get scannedBluetoothDevices {
    return [..._detectedDevices];
  }

  /// function to return [_connectedDevice]
  BluetoothDevice? get getConnectedDevice => _connectedDevice;

  /// function to check whether the device is connected to the OBD-II device
  bool isConnected() {
    return _connectedDevice == null ? false : true;
  }
}
