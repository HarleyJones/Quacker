import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:quacker/client/app_http_client.dart';
import 'package:quacker/client/client_account.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/generated/l10n.dart';

class TwitterRegularAccount {
  static final log = Logger('TwitterRegularAccount');

  static Future<Map<String, dynamic>> _loginFlowToken(
      Map<String, String> headers, String accessToken, String guestToken, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json?flow_name=login';
    if (languageCode != null) {
      url = '$url&lang=$languageCode';
    }
    log.info('Posting (login) $url');
    headers.addAll({'Authorization': 'Bearer $accessToken', 'X-Guest-Token': guestToken});
    var response = await AppHttpClient.httpPost(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'flow_token': null,
          'input_flow_data': {
            'country_code': null,
            'flow_context': {
              'referrer_context': {'referral_details': 'utm_source=google-play&utm_medium=organic', 'referrer_url': ''},
              'start_location': {'location': 'deeplink'}
            },
            'requested_variant': null,
            'target_user_id': 0
          }
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      if (response.headers.containsKey('att')) {
        headers.addAll({'att': response.headers['att'] as String, 'cookie': 'att=${response.headers['att']}'});
      }
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the login flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _userIdentifierFlowToken(
      Map<String, String> headers, String flowToken, String username, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (userIdentifier) $url');
    var response = await AppHttpClient.httpPost(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'enter_text': {'suggestion_id': null, 'text': username, 'link': 'next_link'},
              'subtask_id': 'LoginEnterUserIdentifier'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the userIdentifier flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _passwordFlowToken(
      Map<String, String> headers, String flowToken, String password, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (password) $url');
    var response = await AppHttpClient.httpPost(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'enter_password': {'password': password, 'link': 'next_link'},
              'subtask_id': 'LoginEnterPassword'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the password flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _duplicationCheckFlowToken(
      Map<String, String> headers, String flowToken, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (duplicationCheck) $url');
    var response = await AppHttpClient.httpPost(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'check_logged_in_account': {'link': 'AccountDuplicationCheck_false'},
              'subtask_id': 'AccountDuplicationCheck'
            }
          ]
        }));

    if (response.statusCode == 200) {
      List<String> cookies = [];
      if (headers.containsKey('cookie')) {
        String attCookie = headers['cookie'] as String;
        cookies.add(attCookie);
        headers.remove('cookie');
      }
      if (response.headers.containsKey('auth_token')) {
        cookies.add('auth_token=${response.headers['auth_token']}');
      }
      if (response.headers.containsKey('ct0')) {
        cookies.add('ct0=${response.headers['ct0']}');
      }
      if (cookies.isNotEmpty) {
        headers['cookie'] = cookies.join(';');
      }
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the duplicationCheck flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _twoFactorAuthChallengeFlowToken(
      Map<String, String> headers, String flowToken, String text, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (twoFactorAuthChallenge) $url');
    var response = await AppHttpClient.httpPost(Uri.parse(url),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'enter_text': {'text': text, 'link': 'next_link'},
              'subtask_id': 'LoginTwoFactorAuthChallenge'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the twoFactorAuthChallenge flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _alternateIdentifierFlowToken(
      Map<String, String> headers, String flowToken, String text, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (alternateIdentifier) $url');
    var response = await AppHttpClient.httpPost(Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'enter_text': {'text': text, 'link': 'next_link'},
              'subtask_id': 'LoginEnterAlternateIdentifierSubtask'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the alternateIdentifier flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Future<Map<String, dynamic>> _loginAcidFlowToken(
      Map<String, String> headers, String flowToken, String text, String? languageCode) async {
    String url = 'https://api.twitter.com/1.1/onboarding/task.json';
    if (languageCode != null) {
      url = '$url?lang=$languageCode';
    }
    log.info('Posting (loginAcid) $url');
    var response = await AppHttpClient.httpPost(Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'),
        headers: headers,
        body: json.encode({
          'flow_token': flowToken,
          'subtask_inputs': [
            {
              'enter_text': {'text': text, 'link': 'next_link'},
              'subtask_id': 'LoginAcid'
            }
          ]
        }));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var result = jsonDecode(response.body);
      return result;
    }

    throw TwitterAccountException(
        'Unable to get the loginAcid flow token. The response (${response.statusCode}) from Twitter/X was: ${response.body}');
  }

  static Map<String, dynamic>? _findSubtask(List<dynamic>? subtasks, String subtaskId) {
    if (subtasks == null) {
      return null;
    }
    for (Map<String, dynamic> subtask in subtasks) {
      if (subtask['subtask_id'] == subtaskId) {
        return subtask;
      }
    }
    return null;
  }

  static Future<TwitterTokenEntity> createRegularTwitterToken(BuildContext? context, String? languageCode,
      String username, String password, String? name, String? email, String? phone) async {
    String accessToken = await TwitterAccount.getAccessToken();
    String guestToken = await TwitterAccount.getGuestToken(accessToken);
    Map<String, String> headers = TwitterAccount.initHeaders();
    Map<String, dynamic> res = await _loginFlowToken(headers, accessToken, guestToken, languageCode);
    String flowToken = res['flow_token'];
    Map<String, dynamic>? subtask;
    while ((subtask = _findSubtask(res['subtasks'], 'LoginSuccessSubtask')) == null) {
      if ((subtask = _findSubtask(res['subtasks'], 'LoginEnterUserIdentifier')) != null) {
        res = await _userIdentifierFlowToken(headers, flowToken, username, languageCode);
      } else if ((subtask = _findSubtask(res['subtasks'], 'LoginEnterPassword')) != null) {
        res = await _passwordFlowToken(headers, flowToken, password, languageCode);
      } else if ((subtask = _findSubtask(res['subtasks'], 'AccountDuplicationCheck')) != null) {
        res = await _duplicationCheckFlowToken(headers, flowToken, languageCode);
      } else if ((subtask = _findSubtask(res['subtasks'], 'LoginTwoFactorAuthChallenge')) != null) {
        if (context != null) {
          Map<String, dynamic>? head = subtask!['enter_text']['header'];
          String? text1 = head?['primary_text']['text'];
          String? text2 = head?['secondary_text']['text'];
          if ((text1?.isEmpty ?? true) && (text2?.isEmpty ?? true)) {
            text1 = 'Enter code';
          } else if (text1?.isEmpty ?? true) {
            text1 = text2;
            text2 = null;
          }
          String? text = await _askForInput(context, text1!, text2);
          if (text?.isNotEmpty ?? false) {
            res = await _twoFactorAuthChallengeFlowToken(headers, flowToken, text!, languageCode);
          } else {
            throw TwitterAccountException('No input provided for LoginTwoFactorAuthChallenge');
          }
        } else {
          throw TwitterAccountException('No context to ask for input for LoginTwoFactorAuthChallenge');
        }
      } else if ((subtask = _findSubtask(res['subtasks'], 'LoginEnterAlternateIdentifierSubtask')) != null) {
        if (context != null) {
          Map<String, dynamic>? enterText = subtask!['enter_text'];
          String? text1 = enterText?['primary_text']['text'];
          String? text2 = enterText?['secondary_text']['text'];
          if ((text1?.isEmpty ?? true) && (text2?.isEmpty ?? true)) {
            text1 = 'Enter code';
          } else if (text1?.isEmpty ?? true) {
            text1 = text2;
            text2 = null;
          }
          String? text = await _askForInput(context, text1!, text2);
          if (text?.isNotEmpty ?? false) {
            res = await _alternateIdentifierFlowToken(headers, flowToken, text!, languageCode);
          } else {
            throw TwitterAccountException('No input provided for LoginEnterAlternateIdentifierSubtask');
          }
        } else {
          throw TwitterAccountException('No context to ask for input for LoginEnterAlternateIdentifierSubtask');
        }
      } else if ((subtask = _findSubtask(res['subtasks'], 'LoginAcid')) != null) {
        if (context != null) {
          Map<String, dynamic>? head = subtask!['enter_text']['header'];
          String? text1 = head?['primary_text']['text'];
          String? text2 = head?['secondary_text']['text'];
          if ((text1?.isEmpty ?? true) && (text2?.isEmpty ?? true)) {
            text1 = 'Enter code';
          } else if (text1?.isEmpty ?? true) {
            text1 = text2;
            text2 = null;
          }
          String? text = await _askForInput(context, text1!, text2);
          if (text?.isNotEmpty ?? false) {
            res = await _loginAcidFlowToken(headers, flowToken, text!, languageCode);
          } else {
            throw TwitterAccountException('No input provided for LoginAcid');
          }
        } else {
          throw TwitterAccountException('No context to ask for input for LoginAcid');
        }
      } else {
        throw TwitterAccountException('Don' 't know what to do with ${jsonEncode(res['subtasks'])}');
      }
      flowToken = res['flow_token'];
    }
    Map<String, dynamic>? openAccount = subtask!['open_account'] as Map<String, dynamic>?;
    if (openAccount != null) {
      String screenName = (openAccount['user'] as Map<String, dynamic>)['screen_name'] as String;
      TwitterTokenEntity tte = TwitterTokenEntity(
          guest: false,
          idStr: (openAccount['user'] as Map<String, dynamic>)['id_str'] as String,
          screenName: screenName,
          oauthToken: openAccount['oauth_token'] as String,
          oauthTokenSecret: openAccount['oauth_token_secret'] as String,
          createdAt: DateTime.now(),
          profile: await TwitterAccount.getOrCreateProfile(screenName, password, name, email, phone));
      await TwitterAccount.addTwitterToken(tte);

      return tte;
    }
    throw TwitterAccountException(
        'Unable to create the regular Twitter/X token. The response from Twitter/X was: ${jsonEncode(res)}');
  }

  static Future<String?> _askForInput(BuildContext context, String primaryText, String? secondaryText) async {
    String? returnedText;
    Widget contentWidget;
    if (secondaryText?.isEmpty ?? true) {
      contentWidget = TextField(
        decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
        onChanged: (value) async {
          returnedText = value;
        },
      );
    } else {
      contentWidget = Column(mainAxisSize: MainAxisSize.min, children: [
        Text(secondaryText!, style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize)),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(contentPadding: EdgeInsets.all(5)),
          onChanged: (value) async {
            returnedText = value;
          },
        )
      ]);
    }
    return await showDialog<String?>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(primaryText),
            titleTextStyle: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                color: Theme.of(context).textTheme.titleMedium!.color,
                fontWeight: FontWeight.bold),
            content: contentWidget,
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                child: Text(L10n.current.cancel),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              ElevatedButton(
                child: Text(L10n.current.ok),
                onPressed: () {
                  Navigator.of(context).pop(returnedText);
                },
              ),
            ],
          );
        });
  }
}
