import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:quacker/client/client_regular_account.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/settings/_account.dart';
import 'package:quacker/settings/_general.dart';

class SetupScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    var model = WebFlowAuthModel(PrefService.of(context));

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon.png',
            width: 128,
          ),
          Text(
            L10n.of(context).fritter,
            textScaler: TextScaler.linear(3),
          ),
          languagePicker(),
          InkWell(
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => addDialog(model,
                      pushTo: HomeScreen(
                        key: key,
                      ))),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      width: MediaQuery.sizeOf(context).width - 120,
                      color: Theme.of(context).buttonTheme.colorScheme?.primary,
                      child: Text(
                        L10n.of(context).login,
                        style: TextStyle(fontSize: 25, color: Theme.of(context).buttonTheme.colorScheme?.onPrimary),
                      ))))
        ],
      )),
    );
  }
}
