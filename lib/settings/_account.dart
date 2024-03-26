import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pref/pref.dart';

import '../client/authenticate.dart';

class SettingsAccountFragment extends StatefulWidget {
  State<SettingsAccountFragment> createState() => _SettingsAccountFragment();
}

class _SettingsAccountFragment extends State<SettingsAccountFragment> {
  @override
  Widget build(BuildContext context) {
    var model = context.read<WebFlowAuthModel>();
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.account)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(children: [
          Row(
            children: [
              Flexible(
                child: PrefLabel(
                  title: Text(L10n.of(context).loginNameTwitterAcc),
                ),
              ),
              Flexible(
                child: PrefText(
                  label: '',
                  pref: optionLoginNameTwitterAcc,
                  //style: const TextStyle(fontSize: 16,height:1),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(3, 0, 16, 3),
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: PrefLabel(
                  title: Text(L10n.of(context).passwordTwitterAcc),
                ),
              ),
              Flexible(
                child: PrefText(
                  obscureText: true,
                  label: '',
                  pref: optionPasswordTwitterAcc,
                  //style: const TextStyle(fontSize: 16,height:1),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(3, 0, 16, 3),
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                child: PrefLabel(
                  title: Text(L10n.of(context).emailTwitterAcc),
                ),
              ),
              Flexible(
                child: PrefText(
                  label: '',
                  pref: optionEmailTwitterAcc,
                  //style: const TextStyle(fontSize: 16,height:1),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(3, 0, 16, 3),
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: () async {
                    await model.DeleteAllCookies();
                  },
                  child: Text(L10n.of(context).login)),
              SizedBox(
                width: 10,
              ),
              OutlinedButton(
                  onPressed: () async {
                    await model.DeleteAllCookies();
                    model.prefs.set(optionLoginNameTwitterAcc, "");
                    model.prefs.set(optionPasswordTwitterAcc, "");
                    model.prefs.set(optionEmailTwitterAcc, "");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          L10n.of(context).twitterCookiesDeleted,
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text(L10n.of(context).DeleteTwitterCookies))
            ],
          )
        ]),
      ),
    );
  }
}
