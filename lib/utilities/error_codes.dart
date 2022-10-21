import 'package:ble_app/utilities/enums.dart';

String getErrorCode(Component component, String category, var value) {
  int errorCodeDecimal = int.parse(value, radix: 16);
  String errorReason = '';

  if (component == Component.brain) {
    errorReason = brainErrorCode[category]![errorCodeDecimal] ??
        'Some brain service related error occurred';
  } else if (component == Component.nodes) {
    errorReason;
  }

  return errorReason;
}

Map<String, Map<int, String>> brainErrorCode = {
  'User': {
    4097: 'Memory error, power cycle req',
    4098: 'Technical error, power cycle req',
    4099: 'No network connection',
    4100: 'No GPS connection',
    4101: 'Node not available',
  },
  'Backend': {
    4352: 'IP error',
    4353: 'Communication timeouts',
    4354: 'File error',
    4355: 'GNSS error',
    4357: 'HTTP error',
  },
  'Ble': {
    4608: '',
    4609: 'Error setting advertisement data',
    4610: 'Error enabling advertisement',
    4611: 'Error initialising security',
    4612: 'Device disconnect error',
    4613: 'More than 3 devices',
  }
};

Map<String, Map<int, String>> nodeErrorCode = {
  'User': {
    8193: 'Efuse error',
    12289: 'Sensor not connected',
    12290: 'Lower limit temperature warning',
    12291: 'Upper limit temperature warning',
    20481: 'Temperature sensor not connected',
    20482: 'Lower limit SOC warning (<20%)',
    20483: 'Lower limit SOC error (<10%)',
    20484: 'Battery temperature warning (>60°C)',
    20485: 'Battery temperature error (>90°C)',
    20486: 'Fuse warning -> Min. one fuse not connected',
    24577: 'Sensor not connected',
    24578: 'Lower limit level warning',
    24579: 'Upper limit level warning',
  },
  'Dev': {
    8194: 'Switch related development error',
  },
  'Other': {
    8192: 'Switch related error',
    12288: 'Temperature related error',
    20480: 'Battery related error',
    16384: 'Ambient related error',
    24576: 'Level related error',
  }
};
