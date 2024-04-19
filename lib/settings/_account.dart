import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quacker/client/client_regular_account.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pref/pref.dart';
import 'package:quacker/ui/errors.dart';

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
      body: FutureBuilder(
          future: getAccounts(),
          builder: (BuildContext listContext, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LinearProgressIndicator();
            } else {
              List<Map<String, Object?>> data = snapshot.data;
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext itemContext, int index) {
                    return Card(
                        child: ListTile(
                      title: Text(data[index]['id'].toString()),
                      subtitle: Text(data[index]['email'].toString()),
                      leading: Icon(Icons.account_circle),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await deleteAccount(data[index]['id'].toString());
                          setState(() {});
                        },
                      ),
                      onTap: () => showDialog(
                          context: context,
                          builder: (_) => addDialog(model,
                              username: data[index]['id'],
                              password: data[index]['password'],
                              email: data[index]['email'])),
                    ));
                  });
            }
          }),
    );
  }
}

class addDialog extends StatefulWidget {
  final WebFlowAuthModel model;
  final username;
  final password;
  final email;

  const addDialog(this.model, {super.key, this.username, this.password, this.email});

  @override
  State<addDialog> createState() => _addDialog();
}

class _addDialog extends State<addDialog> {
  bool hidePassword = true;

  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _email = TextEditingController();

  Widget build(BuildContext context) {
    _username.text = widget.username;
    _password.text = widget.password;
    _email.text = widget.email;

    return AlertDialog(
      title: Text(L10n.of(context).account),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          child: TextField(
            controller: _username,
            decoration: InputDecoration(
                isDense: true, label: Text(L10n.of(context).loginNameTwitterAcc), border: const OutlineInputBorder()),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        Flexible(
          child: TextField(
            controller: _password,
            obscureText: hidePassword,
            decoration: InputDecoration(
              isDense: true,
              label: Text(L10n.of(context).passwordTwitterAcc),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        Flexible(
          child: TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                isDense: true, label: Text(L10n.of(context).emailTwitterAcc), border: const OutlineInputBorder()),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "⚠️ 2FA is currently not supported ⚠️",
              textAlign: TextAlign.center,
            )),
      ]),
      actions: [
        TextButton(
            onPressed: () async {
              final response = await addAccount(PrefService.of(context), _username.text, _password.text, _email.text);
              if (context.mounted) {
                showSnackBar(context, icon: '', message: response);
              }
              Navigator.pop(context);

              setState(() {});
            },
            child: Text(L10n.of(context).login)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(L10n.of(context).close)),
      ],
    );
  }
}
