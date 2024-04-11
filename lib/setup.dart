import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:quacker/client/client_regular_account.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/settings/_account.dart';
import 'package:quacker/settings/_general.dart';
import 'package:quacker/subscriptions/_import.dart';

class SetupScreen extends StatelessWidget {
  Widget build(BuildContext context) {
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
          languagePicker()
        ],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetupAccount())),
      ),
    );
  }
}

class SetupAccount extends StatelessWidget {
  Widget build(BuildContext context) {
    var model = WebFlowAuthModel(PrefService.of(context));

    return Scaffold(
      body: Center(
        child: addDialog(model),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ImportSubscriptions())),
      ),
    );
  }
}

class ImportSubscriptions extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: SubscriptionImportScreen(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          PrefService.of(context).set(optionWizardCompleted, true);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        },
      ),
    );
  }
}
