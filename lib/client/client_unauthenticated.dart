import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:quacker/client/app_http_client.dart';

const String unauthenticatedAccessToken =
    'AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA';

class TwitterUnauthenticated {
  static final log = Logger('TwitterUnauthenticated');

  static String? _guestToken;

  static Future<String> getGuestToken() async {
    if (_guestToken != null) {
      return _guestToken!;
    }
    log.info('Posting https://api.twitter.com/1.1/guest/activate.json');
    var response = await AppHttpClient.httpPost(Uri.parse('https://api.twitter.com/1.1/guest/activate.json'),
        headers: {'Authorization': 'Bearer $unauthenticatedAccessToken'});

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      if (result.containsKey('guest_token')) {
        _guestToken = result['guest_token'];
        return _guestToken!;
      }
    }
    throw TwitterUnauthenticatedException(
        'Unable to get the guest token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<http.Response> fetch(Uri uri, {Map<String, String>? headers}) async {
    String guestToken = await getGuestToken();
    var response = await AppHttpClient.httpGet(uri, headers: {
      ...?headers,
      'Authorization': 'Bearer $unauthenticatedAccessToken',
      'Content-Type': 'application/json',
      'X-Twitter-Active-User': 'yes',
      'Authority': 'api.twitter.com',
      'Origin': 'https://twitter.com',
      'Referer': 'https://twitter.com/',
      'Pragma': 'no-cache',
      'cache-control': 'no-cache',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept': '*/*',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      'X-Guest-Token': guestToken,
      'cookie': 'gt=$guestToken'
    });

    return response;
  }
}

class TwitterUnauthenticatedException implements Exception {
  final String message;

  TwitterUnauthenticatedException(this.message);

  @override
  String toString() {
    return message;
  }
}
