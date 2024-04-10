import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pref/pref.dart';
import 'package:quacker/ui/errors.dart';

import '../client/client_regular_account.dart';

class SettingsAccountFragment extends StatefulWidget {
  State<SettingsAccountFragment> createState() => _SettingsAccountFragment();
}

class _SettingsAccountFragment extends State<SettingsAccountFragment> {
  @override
  Widget build(BuildContext context) {
    var model = context.read<WebFlowAuthModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.current.account),
        actions: [
          IconButton(
              onPressed: () => showDialog(context: context, builder: (_) => addDialog(model)),
              icon: const Icon(Icons.add))
        ],
      ),
    );
  }
}

class addDialog extends StatefulWidget {
  final WebFlowAuthModel model;

  const addDialog(this.model, {super.key});

  @override
  State<addDialog> createState() => _addDialog();
}

class _addDialog extends State<addDialog> {
  bool hidePassword = true;
  var multiFactorController = TextEditingController();

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(L10n.of(context).account),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: PrefText(
            pref: optionLoginNameTwitterAcc,
            decoration:
                InputDecoration(label: Text(L10n.of(context).loginNameTwitterAcc), border: const OutlineInputBorder()),
          ),
        ),
        Flexible(
          child: PrefText(
            obscureText: hidePassword,
            pref: optionPasswordTwitterAcc,
            decoration: InputDecoration(
              label: Text(L10n.of(context).passwordTwitterAcc),
              border: const OutlineInputBorder(),
              suffix: IconButton(
                icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
          ),
        ),
        Flexible(
          child: PrefText(
            keyboardType: TextInputType.emailAddress,
            pref: optionEmailTwitterAcc,
            decoration:
                InputDecoration(label: Text(L10n.of(context).emailTwitterAcc), border: const OutlineInputBorder()),
          ),
        ),
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "⚠️ 2FA is currently not supported ⚠️",
              textAlign: TextAlign.center,
            )),
      ]),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
            onPressed: () async {
              try {
                await widget.model.GetAuthHeader(userAgentHeader);
                Navigator.pop(context);
                sleep(Durations.medium1);
                if (context.mounted) {
                  showSnackBar(context, icon: '✅', message: L10n.of(context).login_success);
                }
              } catch (e) {
                Navigator.pop(context);
                sleep(Durations.medium1);
                if (context.mounted) {
                  showSnackBar(context, icon: '🙅', message: e.toString().substring(22).replaceAll('\n', ''));
                }
              }
            },
            child: Text(L10n.of(context).login)),
        OutlinedButton(
            onPressed: () async {
              await widget.model.DeleteAllCookies();
              Navigator.pop(context);
              sleep(Durations.medium1);
              if (context.mounted) {
                showSnackBar(context, icon: '🍪', message: L10n.current.twitterCookiesDeleted);
              }
            },
            child: Text(L10n.of(context).DeleteTwitterCookies))
      ],
    );
  }
}
