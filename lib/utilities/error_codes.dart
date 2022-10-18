import 'package:ble_app/utilities/enums.dart';

String getErrorCode(Components component, int value) {
  return '';
}

Map<int, String> brainError = {
  4097: 'Memory error, power cycle req',
  4098: 'Technical error, power cycle req',
  4099: 'No network connection',
  4100: 'No GPS connection',
  4101: 'Node not available',
  4352: 'IP error',
  4353: 'Communication timeouts',
  4354: 'File error',
  4355: 'GNSS error',
  4357: 'HTTP error',
  4609: 'Error setting advertisement data',
  4610: 'Error enabling advertisement',
  4611: 'Error initialising security',
  4612: 'Device disconnect error',
  4613: 'More than 3 devices',
};

Map<int, String> nodesError = {
  8193: 'Efuse error',
  8192: 'Switch user error codes',
  8194: 'Switch user error codes',
  12289: 'Sensor not connected',
  12290: 'Lower limit temperature warning',
  12291: 'Upper limit temperature warning',
  16384: 'Ambient',
  20481: 'Temperature sensor not connected',
  20482: 'Lower limit SOC warning (<20%)',
  20483: 'Lower limit SOC error (<10%)',
  20484: 'Battery temperature warning (>60°C)',
  20485: 'Battery temperature error (>90°C)',
  20486: 'Fuse warning -> Min. one fuse not connected',
  24577: 'Sensor not connected',
  24578: 'Lower limit level warning',
  24579: 'Upper limit level warning',
};
