import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:quacker/client/app_http_client.dart';
import 'package:quacker/client/client_account.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/utils/iterables.dart';

class TwitterGuestAccount {
  static final log = Logger('TwitterGuestAccount');

  static Future<String> _getWelcomeFlowToken(Map<String, String> headers, String accessToken, String guestToken) async {
    log.info('Posting https://api.twitter.com/1.1/onboarding/task.json?flow_name=welcome');
    headers.addAll({'Authorization': 'Bearer $accessToken', 'X-Guest-Token': guestToken});
    var response =
        await AppHttpClient.httpPost(Uri.parse('https://api.twitter.com/1.1/onboarding/task.json?flow_name=welcome'),
            headers: headers,
            body: json.encode({
              'flow_token': null,
              'input_flow_data': {
                'flow_context': {
                  'start_location': {'location': 'splash_screen'}
                }
              }
            }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      if (result.containsKey('flow_token')) {
        return result['flow_token'];
      }
    }

    throw TwitterAccountException(
        'Unable to get the welcome flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<TwitterTokenEntity> _getGuestTwitterTokenFromTwitter(
      Map<String, String> headers, String flowToken) async {
    log.info('Posting https://api.twitter.com/1.1/onboarding/task.json');
    var response = await AppHttpClient.httpPost(Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'open_link': {'link': 'next_link'},
              'subtask_id': 'NextTaskOpenLink'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      List? subtasks = result['subtasks'];
      if (subtasks != null) {
        var accountElm = subtasks.firstWhereOrNull((task) => task['subtask_id'] == 'OpenAccount');
        if (accountElm != null) {
          var account = accountElm['open_account'];
          log.info(
              "Guest Twitter/X token created! oauth_token=${account['oauth_token']} oauth_token_secret=${account['oauth_token_secret']}");
          return TwitterTokenEntity(
              guest: true,
              idStr: account['user']?['id_str'],
              screenName: account['user']?['screen_name'],
              oauthToken: account['oauth_token'],
              oauthTokenSecret: account['oauth_token_secret'],
              createdAt: DateTime.now());
        }
      }
    }

    throw TwitterAccountException(
        'Unable to create the guest Twitter/X token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<TwitterTokenEntity> createGuestTwitterToken() async {
    String accessToken = await TwitterAccount.getAccessToken();
    String guestToken = await TwitterAccount.getGuestToken(accessToken);
    Map<String, String> headers = TwitterAccount.initHeaders();
    String flowToken = await _getWelcomeFlowToken(headers, accessToken, guestToken);
    TwitterTokenEntity guestTwitterToken = await _getGuestTwitterTokenFromTwitter(headers, flowToken);

    await TwitterAccount.addTwitterToken(guestTwitterToken);
    return guestTwitterToken;
  }
}
