import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pref/pref.dart';

import '../client/authenticate.dart';

class SettingsAccountFragment extends StatelessWidget {
  const SettingsAccountFragment({Key? key}) : super(key: key);

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
                    await model.GetAuthHeader({
                      'user-agent':
                          "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.3",
                      // "Pragma": "no-cache",
                      "Cache-Control": "no-cache"
                      // "If-Modified-Since": "Sat, 1 Jan 2000 00:00:00 GMT",
                    });
                  },
                  child: Text(L10n.of(context).login)),
              SizedBox(
                width: 10,
              ),
              OutlinedButton(
                  onPressed: () async {
                    await model.DeleteAllCookies();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          L10n.of(context).twitterCookiesDeleted,
                        ),
                      ),
                    );
                  },
                  child: Text(L10n.of(context).DeleteTwitterCookies))
            ],
          )
        ]),
      ),
    );
  }
}
