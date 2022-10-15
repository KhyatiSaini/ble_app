import 'package:ble_app/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: const Center(
        child: Text(
          'hey there',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // todo: bluetooth scan functionality
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
