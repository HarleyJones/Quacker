import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pref/pref.dart';
import 'package:quacker/ui/errors.dart';

import '../client/regularAccount.dart';

class SettingsAccountFragment extends StatefulWidget {
  State<SettingsAccountFragment> createState() => _SettingsAccountFragment();
}

class _SettingsAccountFragment extends State<SettingsAccountFragment> {
  var multiFactorController = TextEditingController();
  bool hidePassword = true;

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
                  obscureText: hidePassword,
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
                    suffix: InkWell(
                      onTap: () => setState(() => hidePassword = !hidePassword),
                      child: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
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
                    try {
                      final _authHeader = await model.GetAuthHeader({
                        'user-agent':
                            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.3",
                        // "Pragma": "no-cache",
                        "Cache-Control": "no-cache"
                        // "If-Modified-Since": "Sat, 1 Jan 2000 00:00:00 GMT",
                      }, authCode: null);

                      print(_authHeader);
                    } catch (e) {
                      showSnackBar(context, icon: '', message: e.toString());
                    }
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
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "⚠️ 2FA is currently not supported ⚠️",
                textAlign: TextAlign.center,
              )),
        ]),
      ),
    );
  }
}
