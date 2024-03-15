import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/settings/_about.dart';
import 'package:quacker/settings/_data.dart';
import 'package:quacker/settings/_general.dart';
import 'package:quacker/settings/_home.dart';
import 'package:quacker/settings/_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '_account.dart';

class SettingsScreen extends StatefulWidget {
  final String? initialPage;

  const SettingsScreen({Key? key, this.initialPage}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo _packageInfo = PackageInfo(appName: '', packageName: '', version: '', buildNumber: '');
  String _legacyExportPath = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _packageInfo = packageInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appVersion = 'v${_packageInfo.version}+${_packageInfo.buildNumber}';

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(children: [
        ListTile(
          title: Text(L10n.current.general),
          leading: Icon(Icons.settings),
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => SettingsGeneralFragment())),
        ),
        ListTile(
          title: Text(L10n.current.home),
          leading: Icon(Icons.home_filled),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => SettingsHomeFragment())),
        ),
        ListTile(
          title: Text(L10n.current.theme),
          leading: Icon(Icons.format_paint),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => SettingsThemeFragment())),
        ),
        ListTile(
          title: Text(L10n.current.data),
          leading: Icon(Icons.storage),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext c) => SettingsDataFragment(
                        legacyExportPath: '',
                      ))),
        ),
        ListTile(
          title: Text(L10n.current.account),
          leading: Icon(Icons.account_circle),
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => SettingsAccountFragment())),
        ),
        ListTile(
          title: Text(L10n.current.about),
          leading: Icon(Icons.info),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext c) => SettingsAboutFragment(
                        appVersion: appVersion,
                      ))),
        ),
      ]),
    );
  }
}
