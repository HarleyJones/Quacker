import 'dart:io';
import 'dart:math';

import 'package:quacker/client/app_http_client.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) =>
    String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String? cached_public_ip;

// reference: https://stackoverflow.com/questions/60180934/how-to-get-public-ip-in-flutter
Future<String?> getPublicIP() async {
  try {
    if (cached_public_ip != null) {
      return cached_public_ip;
    }
    var url = Uri.parse('https://api.ipify.org');
    var response = await AppHttpClient.httpGet(url);
    if (response.statusCode == 200) {
      // The response body is the IP in plain text, so just
      // return it as-is.
      cached_public_ip = response.body;
      return cached_public_ip;
    } else {
      // The request failed with a non-200 code
      // The ipify.org API has a lot of guaranteed uptime
      // promises, so this shouldn't ever actually happen.
      print(response.statusCode);
      print(response.body);
      return null;
    }
  } catch (e) {
    // Request failed due to an error, most likely because
    // the phone isn't connected to the internet.
    print(e);
    return null;
  }
}

bool findInJSONArray(List arr, String key, String value) {
  for (var item in arr) {
    if (item[key] == value) {
      return true;
    }
  }
  return false;
}

bool isTranslatable(String? lang, String? text) {
  if (lang == null || lang == 'und') {
    return false;
  }

  if (lang != getShortSystemLocale()) {
    return true;
  }

  return false;
}

String getShortSystemLocale() {
  // TODO: Cache
  return Platform.localeName.split("_")[0];
}
