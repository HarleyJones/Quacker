import 'dart:convert';
import "dart:math";
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pref/pref.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/database/repository.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/client/client_regular_account.dart';

Future<String> addAccount(BasePrefService prefs, String username, String password, String email) async {
  var database = await Repository.writable();
  final model = WebFlowAuthModel(prefs);

  try {
    final authHeader = await model.GetAuthHeader(username: username, password: password, email: email);

    if (authHeader != null) {
      database.insert(
          tableAccounts, {"id": username, "password": password, "email": email, "auth_header": jsonEncode(authHeader)});

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
  } else {
    return null;
  }
}

Future<http.Response?> fetchAuthenticated(Uri uri,
    {Map<String, String>? headers,
    required Logger log,
    required BasePrefService prefs,
    required Map<dynamic, dynamic> authHeader}) async {
  log.info('Fetching $uri');

  WebFlowAuthModel webFlowAuthModel = WebFlowAuthModel(prefs);
  var response = await http.get(uri, headers: {
    ...?headers,
    ...authHeader,
    ...userAgentHeader,
    'authorization': bearerToken,
    'x-guest-token': (await webFlowAuthModel.GetGT(userAgentHeader)).toString(),
    'x-twitter-active-user': 'yes',
    'user-agent': userAgentHeader.toString()
  });

  return response;
}
