import 'package:ble_app/providers/bluetooth_provider.dart';
import 'package:ble_app/providers/bluetooth_status_provider.dart';
import 'package:ble_app/theme/colors.dart';
import 'package:ble_app/utilities/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  static const routeName = '/home';

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    deviceName = deviceID;
                  }

                  return Container(
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
                  );
                },
                itemCount: bluetoothProvider.scannedBluetoothDevices.length,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // todo: bluetooth scan functionality
          BluetoothProvider().startScan();
        },
        backgroundColor: darkBlueGrayColor,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: const Icon(
          CupertinoIcons.search,
        ),
      ),
    );
  }
}
