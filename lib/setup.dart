import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:quacker/client/client_regular_account.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/settings/_account.dart';
import 'package:quacker/subscriptions/_import.dart';

class SetupScreen extends StatefulWidget {
  @override
  State<SetupScreen> createState() => _SetupScreen();
}

class _SetupScreen extends State<SetupScreen> {
  final pages = [WelcomePage(), SetupAccount()];
  int page = 0;

  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[page],
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (page > 0)
                FloatingActionButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    page = page - 1;
                  }),
                ),
              const Spacer(),
              FloatingActionButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () => setState(() {
                  if (page >= pages.length + 1) {
                    PrefService.of(context).set(optionWizardCompleted, true);
                  } else {
                    page = page + 1;
                  }
                }),
              ),
            ],
          ),
        ));
  }
}

class WelcomePage extends StatelessWidget {
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
          )
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
