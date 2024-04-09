import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:pref/pref.dart';

class SettingsThemeFragment extends StatelessWidget {
  const SettingsThemeFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.theme)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(children: [
          PrefDropdown(fullWidth: false, title: Text(L10n.of(context).theme_mode), pref: optionThemeMode, items: [
            DropdownMenuItem(
              value: 'system',
              child: Text(L10n.of(context).system),
            ),
            DropdownMenuItem(
              value: 'light',
              child: Text(L10n.of(context).light),
            ),
            DropdownMenuItem(
              value: 'dark',
              child: Text(L10n.of(context).dark),
            ),
          ]),
          PrefSwitch(
            title: Text(L10n.of(context).true_black),
            pref: optionThemeTrueBlack,
            subtitle: Text(
              L10n.of(context).use_true_black_for_the_dark_mode_theme,
            ),
          ),
          PrefSwitch(
            title: Text(L10n.of(context).show_navigation_labels),
            pref: optionShowNavigationLabels,
          ),
        ]),
      ),
    );
  }
}
