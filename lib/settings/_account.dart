import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pref/pref.dart';
import 'package:quacker/client/client_account.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/generated/l10n.dart';

class SettingsAccountFragment extends StatefulWidget {
  const SettingsAccountFragment({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsAccountFragmentState();
}

class _SettingsAccountFragmentState extends State<SettingsAccountFragment> {
  static final log = Logger('_SettingsAccountFragmentState');

  List<TwitterTokenEntity> _regularAccountsTokens = [];

  @override
  void initState() {
    super.initState();
    _regularAccountsTokens = TwitterAccount.getRegularAccountsTokens();
  }

  @override
  Widget build(BuildContext context) {
    TwitterAccount.setCurrentContext(context);
    BasePrefService prefs = PrefService.of(context);

    return Scaffold(
        appBar: AppBar(title: Text(L10n.current.account)),
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(children: [
              PrefButton(
                title: Text(_regularAccountsTokens.length.toString()),
                child: Icon(Icons.add),
                onTap: () async {
                  var result = await showDialog<bool>(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: AddAccountDialog(),
                        );
                      });
                  if (result != null && result) {
                    setState(() {
                      _regularAccountsTokens = TwitterAccount.getRegularAccountsTokens();
                    });
                  }
                },
              ),
              ListView.builder(
                  itemCount: _regularAccountsTokens.length,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    List<String> infoLst = [];
                    if (_regularAccountsTokens[index].profile!.name?.isNotEmpty ?? false) {
                      infoLst.add(_regularAccountsTokens[index].profile!.name!);
                    }
                    if (_regularAccountsTokens[index].profile!.email?.isNotEmpty ?? false) {
                      infoLst.add(_regularAccountsTokens[index].profile!.email!);
                    }
                    if (_regularAccountsTokens[index].profile!.phone?.isNotEmpty ?? false) {
                      infoLst.add(_regularAccountsTokens[index].profile!.phone!);
                    }
                    return Dismissible(
                      key: Key(_regularAccountsTokens[index].oauthToken),
                      onDismissed: (DismissDirection direction) async {
                        await TwitterAccount.deleteTwitterToken(_regularAccountsTokens[index]);
                        setState(() {
                          _regularAccountsTokens.removeAt(index);
                        });
                      },
                      child: Card(
                          child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(_regularAccountsTokens[index].screenName),
                        subtitle: infoLst.isEmpty ? null : Text(infoLst.join(', ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            var result = await showDialog<bool>(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    child: AddAccountDialog(accountToEdit: _regularAccountsTokens[index].screenName),
                                  );
                                });
                            if (result != null && result) {
                              setState(() {
                                _regularAccountsTokens = TwitterAccount.getRegularAccountsTokens();
                              });
                            }
                          },
                        ),
                      )),
                    );
                  }),
            ])));
  }
}

class AddAccountDialog extends StatefulWidget {
  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
  String? accountToEdit;

  AddAccountDialog({Key? key, this.accountToEdit}) : super(key: key);
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  bool _passwordObscured = true;
  bool _saveEnabled = false;
  String _username = '';
  String _password = '';
  String? _name;
  String? _email;
  String? _phone;
  TextEditingController? _usernameController;
  TextEditingController? _passwordController;
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      _saveEnabled = true;
      _username = widget.accountToEdit!;
      _usernameController = TextEditingController(text: widget.accountToEdit!);
      TwitterProfileEntity? tpe = TwitterAccount.getProfile(widget.accountToEdit!);
      if (tpe != null) {
        _password = tpe.password;
        _passwordController = TextEditingController(text: tpe.password);
        if (tpe.name?.isNotEmpty ?? false) {
          _name = tpe.name;
          _nameController = TextEditingController(text: tpe.name);
        }
        if (tpe.email?.isNotEmpty ?? false) {
          _email = tpe.email;
          _emailController = TextEditingController(text: tpe.email);
        }
        if (tpe.phone?.isNotEmpty ?? false) {
          _phone = tpe.phone;
          _phoneController = TextEditingController(text: tpe.phone);
        }
      }
    }
  }

  void _checkEnabledSave() {
    if (_username.isEmpty || _password.isEmpty) {
      if (_saveEnabled) {
        setState(() {
          _saveEnabled = false;
        });
      }
    } else {
      if (!_saveEnabled) {
        setState(() {
          _saveEnabled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TwitterAccount.setCurrentContext(context);
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
            //physics: NeverScrollableScrollPhysics(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                  child: Text(widget.accountToEdit != null ? "Edit Account" : L10n.current.account,
                      style: TextStyle(fontSize: 20))),
              SizedBox(height: 60),
              Text("required"),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: width / 4,
                  child: Text(L10n.current.username),
                ),
                Expanded(
                  child: TextField(
                    readOnly: widget.accountToEdit != null ? true : false,
                    controller: _usernameController,
                    decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
                    onChanged: (text) {
                      _username = text.trim();
                      _checkEnabledSave();
                    },
                  ),
                )
              ]),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: width / 4,
                  child: Text(L10n.current.passwordTwitterAcc),
                ),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _passwordObscured,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordObscured ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _passwordObscured = !_passwordObscured;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (text) {
                      _password = text.trim();
                      _checkEnabledSave();
                    },
                  ),
                )
              ]),
              SizedBox(height: 20),
              Text("Optional"),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: width / 4,
                  child: Text("name"),
                ),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
                    onChanged: (text) {
                      _name = text.trim();
                    },
                  ),
                ),
              ]),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: width / 4,
                  child: Text(L10n.current.emailTwitterAcc),
                ),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
                    onChanged: (text) {
                      _email = text.trim();
                    },
                  ),
                ),
              ]),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: width / 4,
                  child: Text("phone"),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
                    onChanged: (text) {
                      _phone = text.trim();
                    },
                  ),
                ),
              ]),
              SizedBox(height: 60),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  child: Text(L10n.current.cancel),
                  onPressed: () => Navigator.pop(context, false),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                    child: Text(L10n.current.save,
                        style: TextStyle(
                            color: _saveEnabled
                                ? Theme.of(context).textTheme.labelMedium!.color
                                : Theme.of(context).disabledColor)),
                    onPressed: () async {
                      if (!_saveEnabled) {
                        return;
                      }
                      try {
                        // this creates a new authenticated token and delete the old one if applicable
                        await TwitterAccount.createRegularTwitterToken(_username, _password, _name, _email, _phone);
                        Navigator.pop(context, true);
                      } catch (e, _) {
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("error from twitter"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(L10n.current.ok),
                                    ),
                                  ]);
                            });
                        Navigator.pop(context, false);
                      }
                    }),
              ])
            ])));
  }
}
