import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/settings/_about.dart';
import 'package:quacker/settings/_accessibility.dart';
import 'package:quacker/settings/_account.dart';
import 'package:quacker/settings/_data.dart';
import 'package:quacker/settings/_general.dart';
import 'package:quacker/settings/_home.dart';
import 'package:quacker/settings/_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      appBar: AppBar(title: Text(L10n.of(context).settings)),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ExpansionTile(
              title: Text(
                L10n.of(context).settings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: true,
              dense: true,
              trailing: SizedBox.shrink(),
              enabled: false,
              children: [
                ListTile(
                  title: Text(L10n.of(context).general),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsGeneralFragment()),
                  ),
                ),
                ListTile(
                  title: Text(L10n.of(context).account),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsAccountFragment()),
                  ),
                ),
                ListTile(
                  title: Text(L10n.of(context).home),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsHomeFragment()),
                  ),
                ),
                ListTile(
                  title: Text(L10n.of(context).theme),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsThemeFragment()),
                  ),
                ),
                ListTile(
                  title: Text(L10n.of(context).accessibility),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsAccessibilityFragment()),
                  ),
                ),
              ]),
          ExpansionTile(
              title: Text(
                L10n.of(context).data,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: true,
              dense: true,
              trailing: SizedBox.shrink(),
              enabled: false,
              children: [
                SettingsDataFragment(
                  legacyExportPath: _legacyExportPath,
                )
              ]),
          ExpansionTile(
              title: Text(
                L10n.of(context).app_info,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: true,
              dense: true,
              trailing: SizedBox.shrink(),
              enabled: false,
              children: [
                SettingsAboutFragment(
                  appVersion: appVersion,
                )
              ]),
        ],
      ),
    );
  }
}
