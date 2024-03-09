import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/utils/urls.dart';
import 'package:pref/pref.dart';

class SettingsAboutFragment extends StatelessWidget {
  final String appVersion;

  const SettingsAboutFragment({Key? key, required this.appVersion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.about)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(children: [
          PrefLabel(
            leading: const Icon(Icons.info),
            title: Text(L10n.of(context).version),
            subtitle: Text(appVersion),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: appVersion));

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(L10n.of(context).copied_version_to_clipboard),
              ));
            },
          ),
          PrefLabel(
            leading: const Icon(Icons.favorite),
            title: Text(L10n.of(context).contribute),
            subtitle: Text(L10n.of(context).help_make_fritter_even_better),
            onTap: () => openUri('https://github.com/thehcj/quacker'),
          ),
          PrefLabel(
            leading: const Icon(Icons.bug_report),
            title: Text(L10n.of(context).report_a_bug),
            subtitle: Text(
              L10n.of(context).let_the_developers_know_if_something_is_broken,
            ),
            onTap: () => openUri('https://github.com/thehcj/quacker/issues'),
          ),
          PrefLabel(
            leading: const Icon(Icons.copyright),
            title: Text(L10n.of(context).licenses),
            subtitle: Text(L10n.of(context).all_the_great_software_used_by_fritter),
            onTap: () => showLicensePage(
                context: context,
                applicationName: L10n.of(context).fritter,
                applicationVersion: appVersion,
                applicationLegalese: L10n.of(context).released_under_the_mit_license,
                applicationIcon: Container(
                  margin: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48.0),
                    child: Image.asset(
                      'assets/icon.png',
                      height: 48.0,
                      width: 48.0,
                    ),
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}