import 'package:ble_app/providers/bluetooth_provider.dart';
import 'package:ble_app/providers/bluetooth_status_provider.dart';
import 'package:ble_app/theme/colors.dart';
import 'package:ble_app/utilities/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  static const routeName = '/home';
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            'assets/revotion_gmbh_logo.svg',
            height: 18.0,
          ),
          centerTitle: true,
          leading: const Icon(
            CupertinoIcons.line_horizontal_3,
            color: darkBlackColor,
            size: 30,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              if (bluetoothProvider.scannedBluetoothDevices.isEmpty) {
                return Center(
                  child: Consumer<BluetoothStatusProvider>(
                    builder: (context, bluetoothStatusProvider, child) {
                      if (bluetoothStatusProvider.bluetoothState ==
                          BluetoothConnectionStatus.off) {
                        return const Text(
                          'Please enable bluetooth for the functioning of the app.',
                          style: TextStyle(
                            color: darkBlackColor,
                          ),
                        );
                      } else {
                        return const Text(
                          'Tap on the floating button to start scanning the nearby bluetooth devices.',
                          style: TextStyle(
                            color: darkBlackColor,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                    },
                  ),
                );
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    String deviceName = '';
                    String deviceID = '';

                    BluetoothDevice bluetoothDevice =
                        bluetoothProvider.scannedBluetoothDevices[index];

                    deviceID = bluetoothDevice.id.id;

                    if (bluetoothDevice.name.trim().isNotEmpty) {
                      deviceName = bluetoothDevice.name.trim();
                    } else {
                      deviceName = 'Bluetooth Device $deviceID';
                    }

                    return InkWell(
                      onTap: () async {
                        bool connected = await BluetoothProvider()
                            .connectToDevice(bluetoothDevice);
                        if (connected) {
                          /// if connected, discover the services and read characteristics via [BluetoothProvider]
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Successfully connected to $deviceName'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            behavior: SnackBarBehavior.floating,
                            dismissDirection: DismissDirection.down,
                            margin: const EdgeInsets.all(16),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                const Text('Cannot connect to this device'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            behavior: SnackBarBehavior.floating,
                            dismissDirection: DismissDirection.down,
                            margin: const EdgeInsets.all(16),
                          ));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          top: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGrayColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                style: const TextStyle(
                                  color: darkBlackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                deviceID,
                                style: const TextStyle(
                                  color: darkBlackColor,
                                ),
                              ),
                            ],
                          )
                        ]),
                      ),
                    );
                  },
                  itemCount: bluetoothProvider.scannedBluetoothDevices.length,
                );
              }
            },
          ),
        ),
        floatingActionButton: Consumer<BluetoothStatusProvider>(
          builder: (context, bluetoothStatusProvider, child) {
            bool bluetoothStatus = (bluetoothStatusProvider.bluetoothState ==
                    BluetoothConnectionStatus.on)
                ? true
                : false;

            return FloatingActionButton(
              onPressed: () {
                /// if bluetooth is turned on, start the scan by calling [startScan] function of [BluetoothProvider]
                /// else display a dialog box asking the user to turn on bluetooth for using the app
                if (bluetoothStatus) {
                  BluetoothProvider().startScan();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Center(
                                child: CircleAvatar(
                                  backgroundColor: darkBlueGrayColor,
                                  radius: 35,
                                  child: Icon(
                                    Icons.bluetooth_rounded,
                                    color: whiteColor,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  'The scan button is disabled, please turn on bluetooth to enable the button. Then start the scan by tapping on the search button near bottom right.',
                                  style: TextStyle(
                                    color: darkBlackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                color: darkBlueGrayColor,
                                minWidth: double.infinity,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Okay',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              backgroundColor: darkBlueGrayColor,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Icon(
                bluetoothStatus
                    ? CupertinoIcons.search
                    : Icons.bluetooth_disabled_rounded,
              ),
            );
          },
        ),
      ),
    );
  }
}
