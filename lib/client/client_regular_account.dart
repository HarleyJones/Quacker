import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pref/pref.dart';
import 'dart:async';
import "dart:math";
import 'package:quacker/constants.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/database/repository.dart';

class XRegularAccount extends ChangeNotifier {
  static final log = Logger('XRegularAccount');

  XRegularAccount() : super();

  Future<http.Response?> fetch(Uri uri,
      {Map<String, String>? headers,
      required Logger log,
      required BasePrefService prefs,
      required Map<dynamic, dynamic> authHeader}) async {
    log.info('Fetching $uri');

    var response = await http.get(uri, headers: {
      ...?headers,
      ...authHeader,
      ...userAgentHeader,
      'authorization': bearerToken,
      'x-twitter-active-user': 'yes',
      'user-agent': userAgentHeader.toString()
    });

    return response;
  }

  Future<List<Map<String, Object?>>> getAccounts() async {
    var database = await Repository.readOnly();
    return database.query(tableAccounts);
  }

  Future<void> deleteAccount(String username) async {
    var database = await Repository.writable();
    database.delete(tableAccounts, where: 'id = ?', whereArgs: [username]);
  }

  Future<Map<dynamic, dynamic>?> getAuthHeader(BasePrefService prefs) async {
    final accounts = await getAccounts();

    if (accounts.isNotEmpty) {
      Account account = Account.fromMap(accounts[Random().nextInt(accounts.length)]);
      final authHeader = Map.castFrom<String, dynamic, String, String>(json.decode(account.authHeader));

      return authHeader;
    } else {
      return null;
    }
  }
}
