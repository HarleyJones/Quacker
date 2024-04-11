import 'dart:convert';
import "dart:math";
import 'package:pref/pref.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/database/repository.dart';
import 'package:quacker/generated/l10n.dart';

import 'client_regular_account.dart';

Future<String> addAccount(BasePrefService prefs, String username, String password, String email) async {
  var database = await Repository.writable();
  final model = WebFlowAuthModel(prefs);

  try {
    final authHeader = await model.GetAuthHeader(username: username, password: password, email: email);

    if (authHeader != null) {
      database.insert(
          tableAccounts, {"id": username, "password": password, "email": email, "authHeader": json.encode(authHeader)});

      return L10n.current.login_success;
    } else {
      return L10n.current.oops_something_went_wrong;
    }
  } catch (e) {
    return e.toString();
  }
}

Future<void> deleteAccount(String username) async {
  var database = await Repository.writable();
  database.delete(tableAccounts, where: 'id = ?', whereArgs: [username]);
}

Future<List<Map<String, Object?>>> getAccounts() async {
  var database = await Repository.readOnly();

  return database.query(tableAccounts);
}

Future<Map<dynamic, dynamic>?> getAuthHeader(BasePrefService prefs) async {
  final accounts = await getAccounts();
  final model = WebFlowAuthModel(prefs);

  if (accounts.isNotEmpty) {
    Map<String, Object?> account = accounts[Random().nextInt(accounts.length)];

    return await model.GetAuthHeader(
        username: account['id'].toString(),
        password: account['password'].toString(),
        email: account['email'].toString());
  }
  return null;
}
