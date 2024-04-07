import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/utils/iterables.dart';
import 'package:pref/pref.dart';

class SettingsAccessibilityFragment extends StatelessWidget {
  const SettingsAccessibilityFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.accessibility)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(children: [
          PrefSwitch(
            title: Text(L10n.of(context).disable_animations),
            pref: optionDisableAnimations,
            subtitle: Text(
              L10n.of(context).disable_animations_description,
            ),
          ),
        ]),
      ),
    );
  }
}
