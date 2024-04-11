// DO NOT ADD NEW FEATURES HErE
// Instead put your code in the NEWclient_regular_account.dart file

import 'dart:convert';
import 'dart:io';
import 'package:dart_twitter_api/api/twitter_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pref/pref.dart';
import 'dart:async';

import 'package:dart_twitter_api/src/utils/date_utils.dart';
import 'package:dart_twitter_api/twitter_api.dart';
import 'package:faker/faker.dart';
import 'package:ffcache/ffcache.dart';
import 'package:quacker/client/NEWclient_regular_account.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/profile/profile_model.dart';
import 'package:quacker/user.dart';
import 'package:quacker/utils/iterables.dart';
import 'package:quiver/iterables.dart';

import '../constants.dart';

const String bearerToken =
    "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA";

const Duration _defaultTimeout = Duration(seconds: 30);
const String _accessToken =
    'AAAAAAAAAAAAAAAAAAAAAGHtAgAAAAAA%2Bx7ILXNILCqkSGIzy6faIHZ9s3Q%3DQy97w6SIrzE7lQwPJEYQBsArEE2fC25caFwRBvAGi456G09vGR';

class AuthenticatedTwitterClient extends TwitterClient {
  static final log = Logger('_FritterTwitterClient');

  AuthenticatedTwitterClient() : super(consumerKey: '', consumerSecret: '', token: '', secret: '');

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers, Duration? timeout}) {
    return fetch(uri, headers: headers).timeout(timeout ?? _defaultTimeout).then((response) {
      if (response?.statusCode != null && response!.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else if (response?.statusCode != null && response!.statusCode == 429) {
        return Future.error(jsonDecode(response.body)['errors'][0]['message'].toString().replaceAll('.', ''));
      } else {
        return Future.error(
            HttpException(response?.reasonPhrase ?? response?.statusCode.toString() ?? "unknown error"));
      }
    });
  }

  static Future<http.Response?> fetch(Uri uri, {Map<String, String>? headers}) async {
    log.info('Fetching $uri');

    var prefs = await PrefServiceShared.init(prefix: 'pref_');

    WebFlowAuthModel webFlowAuthModel = WebFlowAuthModel(prefs);
    Map<dynamic, dynamic>? authHeader = await getAuthHeader(prefs);
    if (authHeader != null) {
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
    return null;
  }
}

class UnknownProfileResultType implements Exception {
  final String type;
  final String message;
  final String uri;

  UnknownProfileResultType(this.type, this.message, this.uri);

  @override
  String toString() {
    return 'Unknown profile result type: {type: $type, message: $message, uri: $uri}';
  }
}

class UnknownProfileUnavailableReason implements Exception {
  final String reason;
  final String uri;

  UnknownProfileUnavailableReason(this.reason, this.uri);

  @override
  String toString() {
    return 'Unknown profile unavailable reason: {reason: $reason, uri: $uri}';
  }
}

class Twitter {
  static final TwitterApi _twitterApi = TwitterApi(client: AuthenticatedTwitterClient());

  static final FFCache _cache = FFCache();

  static Map<String, String> defaultParams = {
    'include_profile_interstitial_type': '1',
    'include_blocking': '1',
    'include_blocked_by': '1',
    'include_followed_by': '1',
    'include_mute_edge': '1',
    'include_can_dm': '1',
    'include_can_media_tag': '1',
    'include_ext_has_nft_avatar': '1',
    'include_ext_is_blue_verified': '1',
    'skip_status': '1',
    'cards_platform': 'Web-12',
    'include_cards': '1',
    'include_ext_alt_text': 'true',
    'include_ext_limited_action_results': 'false',
    'include_quote_count': 'true',
    'include_reply_count': '1',
    'tweet_mode': 'extended',
    'include_ext_collab_control': 'true',
    'include_entities': 'true',
    'include_user_entities': 'true',
    'include_ext_media_color': 'true',
    'include_ext_media_availability': 'true',
    'include_ext_sensitive_media_warning': 'true',
    'include_ext_trusted_friends_metadata': 'true',
    'send_error_codes': 'true',
    'simple_quoted_tweet': 'true',
    'pc': '1',
    'spelling_corrections': '1',
    'include_ext_edit_control': 'true',
    'ext':
        'mediaStats,highlightedLabel,hasNftAvatar,voiceInfo,enrichments,superFollowMetadata,unmentionInfo,editControl,collab_control,vibe,'
  };

  static Future<Profile> getProfileById(String id) async {
    var uri = Uri.https('twitter.com', '/i/api/graphql/Lxg1V9AiIzzXEiP2c8dRnw/UserByRestId', {
      'variables': jsonEncode({
        'userId': id,
        'withHighlightedLabel': true,
        'withSafetyModeUserFields': true,
        'withSuperFollowsUserFields': true
      }),
      'features': jsonEncode({
        'hidden_profile_likes_enabled': false,
        'responsive_web_graphql_exclude_directive_enabled': true,
        'verified_phone_label_enabled': false,
        'highlights_tweets_tab_ui_enabled': true,
        'creator_subscriptions_tweet_preview_api_enabled': true,
        'responsive_web_graphql_skip_user_profile_image_extensions_enabled': false,
        'responsive_web_graphql_timeline_navigation_enabled': true
      })
    });

    return _getProfile(uri);
  }

  static Future<Profile> getProfileByScreenName(String screenName) async {
    var uri = Uri.https('twitter.com', '/i/api/graphql/oUZZZ8Oddwxs8Cd3iW3UEA/UserByScreenName', {
      'variables': jsonEncode({
        'screen_name': screenName,
        'withHighlightedLabel': true,
        'withSafetyModeUserFields': true,
        'withSuperFollowsUserFields': true
      }),
      'features': jsonEncode({
        'hidden_profile_likes_enabled': false,
        'responsive_web_graphql_exclude_directive_enabled': true,
        'verified_phone_label_enabled': false,
        'subscriptions_verification_info_verified_since_enabled': true,
        'highlights_tweets_tab_ui_enabled': true,
        'creator_subscriptions_tweet_preview_api_enabled': true,
        'responsive_web_graphql_skip_user_profile_image_extensions_enabled': false,
        'responsive_web_graphql_timeline_navigation_enabled': true
      })
    });

    return _getProfile(uri);
  }

  static Future<Profile> _getProfile(Uri uri) async {
    var response = await _twitterApi.client.get(uri);
    var content = jsonDecode(response.body) as Map<String, dynamic>;

    var hasErrors = content.containsKey('errors');
    if (hasErrors && content['errors'] != null) {
      var errors = List.from(content['errors']);
      if (errors.isEmpty) {
        throw TwitterError(code: 0, message: 'Unknown error', uri: uri.toString());
      } else {
        throw TwitterError(code: errors.first['code'], message: errors.first['message'], uri: uri.toString());
      }
    }

    var result = content['data']?['user']?['result'];
    if (result == null) {
      throw TwitterError(uri: uri.toString(), code: 50, message: L10n.current.user_not_found);
    }

    var resultType = result['__typename'];
    if (resultType != null) {
      switch (resultType) {
        case 'UserUnavailable':
          var code = result['reason'];
          if (code == 'Suspended') {
            throw TwitterError(code: 63, message: result['reason'], uri: uri.toString());
          } else {
            throw TwitterError(code: -1, message: result['reason'], uri: uri.toString());
          }
        case 'User':
          // This means everything's fine
          break;
      }
    }

    var user = UserWithExtra.fromJson(
        {...result['legacy'], 'id_str': result['rest_id'], 'ext_is_blue_verified': result['is_blue_verified']});
    var pins = List<String>.from(result['legacy']['pinned_tweet_ids_str']);

    return Profile(user, pins);
  }

  static Future<Follows> getProfileFollows(String screenName, String type, {int? cursor, int? count = 200}) async {
    var response = type == 'following'
        ? await _twitterApi.userService
            .friendsList(screenName: screenName, cursor: cursor, count: count, skipStatus: true)
        : await _twitterApi.userService
            .followersList(screenName: screenName, cursor: cursor, count: count, skipStatus: true);

    return Follows(
        cursorBottom: int.parse(response.nextCursorStr ?? '-1'),
        cursorTop: int.parse(response.previousCursorStr ?? '-1'),
        users: response.users?.map((e) => UserWithExtra.fromJson(e.toJson())).toList() ?? []);
  }

  static List<TweetChain> createTweetChains(List<dynamic> addEntries) {
    List<TweetChain> replies = [];

    for (var entry in addEntries) {
      var entryId = entry['entryId'] as String;
      if (entryId.startsWith('tweet-')) {
        var result = entry['content']['itemContent']['tweet_results']['result'];

        replies
            .add(TweetChain(id: result['rest_id'], tweets: [TweetWithCard.fromGraphqlJson(result)], isPinned: false));
      }

      if (entryId.startsWith('cursor-bottom') || entryId.startsWith('cursor-showMore')) {
        // TODO: Use as the "next page" cursor
      }

      if (entryId.startsWith('conversationthread')) {
        List<TweetWithCard> tweets = [];

        // TODO: This is missing tombstone support
        for (var item in entry['content']['items']) {
          var itemType = item['item']?['itemContent']?['itemType'];
          if (itemType == 'TimelineTweet') {
            if (item['item']['itemContent']['tweet_results']?['result'] != null) {
              tweets.add(TweetWithCard.fromGraphqlJson(item['item']['itemContent']['tweet_results']['result']));
            }
          }
        }

        // TODO: There must be a better way of getting the conversation ID
        replies.add(TweetChain(id: entryId.replaceFirst('conversationthread-', ''), tweets: tweets, isPinned: false));
      }
    }

    return replies;
  }

  static Future<TweetStatus> getTweet(String id, {String? cursor}) async {
    var variables = {
      'focalTweetId': id,
      'referrer': 'tweet',
      'with_rux_injections': false,
      'includePromotedContent': true,
      'withCommunity': true,
      'withQuickPromoteEligibilityTweetFields': true,
      'withBirdwatchNotes': false,
      'withVoice': true,
      'withV2Timeline': true
    };

    if (cursor != null) {
      variables['cursor'] = cursor;
    }

    var response =
        await _twitterApi.client.get(Uri.https('twitter.com', '/i/api/graphql/3XDB26fBve-MmjHaWTUZxA/TweetDetail', {
      'variables': jsonEncode(variables),
      'features': jsonEncode({
        'rweb_lists_timeline_redesign_enabled': true,
        'responsive_web_graphql_exclude_directive_enabled': true,
        'verified_phone_label_enabled': false,
        'creator_subscriptions_tweet_preview_api_enabled': true,
        'responsive_web_graphql_timeline_navigation_enabled': true,
        'responsive_web_graphql_skip_user_profile_image_extensions_enabled': false,
        'tweetypie_unmention_optimization_enabled': true,
        'responsive_web_edit_tweet_api_enabled': true,
        'graphql_is_translatable_rweb_tweet_is_translatable_enabled': true,
        'view_counts_everywhere_api_enabled': true,
        'longform_notetweets_consumption_enabled': true,
        'responsive_web_twitter_article_tweet_consumption_enabled': false,
        'tweet_awards_web_tipping_enabled': false,
        'freedom_of_speech_not_reach_fetch_enabled': true,
        'standardized_nudges_misinfo': true,
        'tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled': true,
        'longform_notetweets_rich_text_read_enabled': true,
        'longform_notetweets_inline_media_enabled': true,
        'responsive_web_media_download_video_enabled': false,
        'responsive_web_enhance_cards_enabled': false,
      }),
    }));

    var result = json.decode(response.body);

    var instructions = List.from(result?['data']?['threaded_conversation_with_injections_v2']?['instructions']);
    if (instructions.isEmpty) {
      return TweetStatus(chains: [], cursorBottom: null, cursorTop: null);
    }

    var addEntriesInstructions = instructions.firstWhereOrNull((e) => e['type'] == 'TimelineAddEntries');
    if (addEntriesInstructions == null) {
      return TweetStatus(chains: [], cursorBottom: null, cursorTop: null);
    }

    var addEntries = List.from(addEntriesInstructions['entries']);
    var repEntries = List.from(instructions.where((e) => e['type'] == 'TimelineReplaceEntry'));

    // TODO: Could this use createUnconversationedChains at some point?
    var chains = createTweetChains(addEntries);

    String? cursorBottom = getCursor(addEntries, repEntries, 'cursor-bottom', 'Bottom');
    String? cursorTop = getCursor(addEntries, repEntries, 'cursor-top', 'Top');

    return TweetStatus(chains: chains, cursorBottom: cursorBottom, cursorTop: cursorTop);
  }

  static Future<List<UserWithExtra>> searchUsers(String query, {int limit = 25, String? maxId, String? cursor}) async {
    var queryParameters = {
      ...defaultParams,
      'count': limit.toString(),
      'max_id': maxId,
      'q': query,
      'pc': '1',
      'spelling_corrections': '1',
      'result_filter': 'user'
    };

    if (cursor != null) {
      queryParameters['cursor'] = cursor;
    }

    var response =
        await _twitterApi.client.get(Uri.https('api.twitter.com', '/1.1/users/search.json', queryParameters));

    List result = json.decode(response.body);

    if (result.isEmpty) {
      return [];
    }

    return result.map((e) => UserWithExtra.fromJson(e)).toList();
  }

  static String? getCursor(List<dynamic> addEntries, List<dynamic> repEntries, String legacyType, String type) {
    String? cursor;

    Map<String, dynamic>? cursorEntry;

    var isLegacyCursor = addEntries.any((element) => element['entryId'].startsWith('cursor'));
    if (isLegacyCursor) {
      cursorEntry = addEntries.firstWhere((e) => e['entryId'].contains(legacyType), orElse: () => null);
    } else {
      cursorEntry = addEntries
          .where((e) => e['entryId'].startsWith('sq-C'))
          .firstWhere((e) => e['content']['operation']['cursor']['cursorType'] == type, orElse: () => null);
    }

    if (cursorEntry != null) {
      var content = cursorEntry['content'];
      if (content.containsKey('value')) {
        cursor = content['value'];
      } else if (content.containsKey('operation')) {
        cursor = content['operation']['cursor']['value'];
      } else {
        cursor = content['itemContent']['value'];
      }
    } else {
      // Look for a "replaceEntry" with the cursor
      var cursorReplaceEntry = repEntries.firstWhere(
          (e) => e.containsKey('replaceEntry')
              ? e['replaceEntry']['entryIdToReplace'].contains(type)
              : e['entry']['content']['cursorType'].contains(type),
          orElse: () => null);

      if (cursorReplaceEntry != null) {
        cursor = cursorReplaceEntry.containsKey('replaceEntry')
            ? cursorReplaceEntry['replaceEntry']['entry']['content']['operation']['cursor']['value']
            : cursorReplaceEntry['entry']['content']['value'];
      }
    }

    return cursor;
  }

  static TweetStatus createUnconversationedChains(Map<String, dynamic> result, String tweetIndicator,
      List<String> pinnedTweets, bool mapToThreads, bool includeReplies) {
    var instructions = List.from(result['timeline']['instructions']);
    if (instructions.isEmpty || !instructions.any((e) => e.containsKey('addEntries'))) {
      return TweetStatus(chains: [], cursorBottom: null, cursorTop: null);
    }

    var addEntries = List.from(instructions.firstWhere((e) => e.containsKey('addEntries'))['addEntries']['entries']);
    var repEntries = List.from(instructions.where((e) => e.containsKey('replaceEntry')));

    String? cursorBottom = getCursor(addEntries, repEntries, 'cursor-bottom', 'Bottom');
    String? cursorTop = getCursor(addEntries, repEntries, 'cursor-top', 'Top');

    var tweets = _createTweets(tweetIndicator, result, includeReplies);

    // First, get all the IDs of the tweets we need to display
    var tweetEntries = addEntries
        .where((e) => e['entryId'].contains(tweetIndicator))
        .sorted((a, b) => b['sortIndex'].compareTo(a['sortIndex']))
        .map((e) => e['content']['item']['content']['tweet']['id'])
        .cast<String>()
        .toList();

    Map<String, List<TweetWithCard>> conversations =
        tweets.values.where((e) => tweetEntries.contains(e.idStr)).groupBy((e) {
      // TODO: I don't think a flag is the right way to handle this
      if (mapToThreads) {
        // Then group the tweets-to-display by their conversation ID
        return e.conversationIdStr;
      }

      return e.idStr;
    }).cast<String, List<TweetWithCard>>();

    List<TweetChain> chains = [];

    // Order all the conversations by newest first (assuming the ID is an incrementing key), and create a chain from them
    for (var conversation in conversations.entries.sorted((a, b) => b.key.compareTo(a.key))) {
      var chainTweets = conversation.value.sorted((a, b) => a.idStr!.compareTo(b.idStr!)).toList();

      chains.add(TweetChain(id: conversation.key, tweets: chainTweets, isPinned: false));
    }

    // If we want to show pinned tweets, add them before the chains that we already have
    if (pinnedTweets.isNotEmpty) {
      for (var id in pinnedTweets) {
        // It's possible for the pinned tweet to either not exist, or not be returned, so handle that
        if (tweets.containsKey(id)) {
          chains.insert(0, TweetChain(id: id, tweets: [tweets[id]!], isPinned: true));
        }
      }
    }

    return TweetStatus(chains: chains, cursorBottom: cursorBottom, cursorTop: cursorTop);
  }

  static Future<List<UserWithExtra>> getUsers(Iterable<String> ids) async {
    // Split into groups of 100, as the API only supports that many at a time
    List<Future<List<UserWithExtra>>> futures = [];

    var groups = partition(ids, 100);
    for (var group in groups) {
      futures.add(_getUsersPage(group));
    }

    return (await Future.wait(futures)).expand((element) => element).toList();
  }

  static Future<List<UserWithExtra>> _getUsersPage(Iterable<String> ids) async {
    var response = await _twitterApi.client.get(Uri.https('api.twitter.com', '/1.1/users/lookup.json', {
      'user_id': ids.join(','),
    }));

    var result = json.decode(response.body);

    return List.from(result).map((e) => UserWithExtra.fromJson(e)).toList(growable: false);
  }

  static Map<String, TweetWithCard> _createTweets(
      String entryPrefix, Map<String, dynamic> result, bool includeReplies) {
    var globalTweets = result['globalObjects']['tweets'] as Map<String, dynamic>;
    var globalUsers = result['globalObjects']['users'];

    bool includeTweet(dynamic t) {
      if (includeReplies) {
        return true;
      }

      return t['in_reply_to_status_id'] == null || t['in_reply_to_user_id'] == null;
    }

    var tweets = globalTweets.values
        .where(includeTweet)
        .map((e) => TweetWithCard.fromCardJson(globalTweets, globalUsers, e))
        .toList();

    return {for (var e in tweets) e.idStr!: e};
  }

  static Future<Map<String, dynamic>> getBroadcastDetails(String key) async {
    var response = await _twitterApi.client.get(Uri.https('twitter.com', '/i/api/1.1/live_video_stream/status/$key'));

    return json.decode(response.body);
  }
}

class TweetWithCard extends Tweet {
  String? noteText;
  Map<String, dynamic>? card;
  String? conversationIdStr;
  TweetWithCard? quotedStatusWithCard;
  TweetWithCard? retweetedStatusWithCard;
  bool? isTombstone;

  TweetWithCard();

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['card'] = card;
    json['conversationIdStr'] = conversationIdStr;
    json['quotedStatusWithCard'] = quotedStatusWithCard?.toJson();
    json['retweetedStatusWithCard'] = retweetedStatusWithCard?.toJson();
    json['isTombstone'] = isTombstone;

    return json;
  }

  factory TweetWithCard.tombstone(dynamic e) {
    var tweetWithCard = TweetWithCard();
    tweetWithCard.idStr = '';
    tweetWithCard.isTombstone = true;
    tweetWithCard.text = ((e['richText']?['text'] ?? e['text'] ?? L10n.current.this_tweet_is_unavailable) as String)
        .replaceFirst(' Learn more', '');

    return tweetWithCard;
  }

  factory TweetWithCard.fromJson(Map<String, dynamic> e) {
    var tweet = Tweet.fromJson(e);

    var tweetWithCard = TweetWithCard();
    tweetWithCard.card = e['card'];
    tweetWithCard.conversationIdStr = e['conversationIdStr'];
    tweetWithCard.createdAt = tweet.createdAt;
    tweetWithCard.entities = tweet.entities;
    tweetWithCard.displayTextRange = tweet.displayTextRange;
    tweetWithCard.extendedEntities = tweet.extendedEntities;
    tweetWithCard.favorited = tweet.favorited;
    tweetWithCard.favoriteCount = tweet.favoriteCount;
    tweetWithCard.fullText = tweet.fullText;
    tweetWithCard.idStr = tweet.idStr;
    tweetWithCard.inReplyToScreenName = tweet.inReplyToScreenName;
    tweetWithCard.inReplyToStatusIdStr = tweet.inReplyToStatusIdStr;
    tweetWithCard.inReplyToUserIdStr = tweet.inReplyToUserIdStr;
    tweetWithCard.isQuoteStatus = tweet.isQuoteStatus;
    tweetWithCard.isTombstone = e['is_tombstone'];
    tweetWithCard.lang = tweet.lang;
    tweetWithCard.quoteCount = tweet.quoteCount;
    tweetWithCard.quotedStatusIdStr = tweet.quotedStatusIdStr;
    tweetWithCard.quotedStatusPermalink = tweet.quotedStatusPermalink;
    tweetWithCard.quotedStatusWithCard =
        e['quotedStatusWithCard'] == null ? null : TweetWithCard.fromJson(e['quotedStatusWithCard']);
    tweetWithCard.replyCount = tweet.replyCount;
    tweetWithCard.retweetCount = tweet.retweetCount;
    tweetWithCard.retweeted = tweet.retweeted;
    tweetWithCard.retweetedStatus = tweet.retweetedStatus;
    tweetWithCard.retweetedStatusWithCard =
        e['retweetedStatusWithCard'] == null ? null : TweetWithCard.fromJson(e['retweetedStatusWithCard']);
    tweetWithCard.source = tweet.source;
    tweetWithCard.text = tweet.text;
    tweetWithCard.user = tweet.user;

    tweetWithCard.coordinates = tweet.coordinates;
    tweetWithCard.truncated = tweet.truncated;
    tweetWithCard.place = tweet.place;
    tweetWithCard.possiblySensitive = tweet.possiblySensitive;
    tweetWithCard.possiblySensitiveAppealable = tweet.possiblySensitiveAppealable;

    return tweetWithCard;
  }

  factory TweetWithCard.fromGraphqlJson(Map<String, dynamic> result) {
    var retweetedStatus = result['retweeted_status_result'] == null
        ? null
        : TweetWithCard.fromGraphqlJson(result['retweeted_status_result']['result']);
    var quotedStatus = result['quoted_status_result'] == null
        ? null
        : TweetWithCard.fromGraphqlJson(result['quoted_status_result']['result']);
    var resCore = result['core']?['user_results']?['result'];
    var user = resCore?['legacy'] == null
        ? null
        : UserWithExtra.fromJson(
            {...resCore['legacy'], 'id_str': resCore['rest_id'], 'ext_is_blue_verified': resCore['is_blue_verified']});

    String? noteText;
    Entities? noteEntities;

    var noteResult = result['note_tweet']?['note_tweet_results']?['result'];
    if (noteResult != null) {
      noteText = noteResult['text'];
      noteEntities = Entities.fromJson(noteResult['entity_set']);
    }

    TweetWithCard tweet =
        TweetWithCard.fromData(result['legacy'], noteText, noteEntities, user, retweetedStatus, quotedStatus);
    if (tweet.card == null && result['card']?['legacy'] != null) {
      tweet.card = result['card']['legacy'];
      List bindingValuesList = tweet.card!['binding_values'] as List;
      Map<String, dynamic> bindingValues = bindingValuesList.fold({}, (prev, elm) {
        prev[elm['key']] = elm['value'];
        return prev;
      });
      tweet.card!['binding_values'] = bindingValues;
    }
    return tweet;
  }

  factory TweetWithCard.fromCardJson(Map<String, dynamic> tweets, Map<String, dynamic> users, Map<String, dynamic> e) {
    var user = e['user_id_str'] == null ? null : UserWithExtra.fromJson(users[e['user_id_str']]);

    var retweetedStatus = e['retweeted_status_id_str'] == null
        ? null
        : TweetWithCard.fromCardJson(tweets, users, tweets[e['retweeted_status_id_str']]);

    // Some quotes aren't returned, even though we're given their ID, so double check and don't fail with a null value
    TweetWithCard? quotedStatus;
    var quoteId = e['quoted_status_id_str'];
    if (quoteId != null && tweets[quoteId] != null) {
      quotedStatus = TweetWithCard.fromCardJson(tweets, users, tweets[quoteId]);
    }

    return TweetWithCard.fromData(e, null, null, user, retweetedStatus, quotedStatus);
  }

  factory TweetWithCard.fromData(Map<String, dynamic> e, String? noteText, Entities? noteEntities, UserWithExtra? user,
      TweetWithCard? retweetedStatus, TweetWithCard? quotedStatus) {
    TweetWithCard tweet = TweetWithCard();
    tweet.card = e['card'];
    tweet.conversationIdStr = e['conversation_id_str'];
    tweet.createdAt = convertTwitterDateTime(e['created_at']);
    tweet.entities = e['entities'] == null ? null : Entities.fromJson(e['entities']);
    tweet.extendedEntities = e['extended_entities'] == null ? null : Entities.fromJson(e['extended_entities']);
    tweet.favorited = e['favorited'] as bool?;
    tweet.favoriteCount = e['favorite_count'] as int?;
    tweet.fullText = e['full_text'] as String?;
    tweet.idStr = e['id_str'] as String?;
    tweet.inReplyToScreenName = e['in_reply_to_screen_name'] as String?;
    tweet.inReplyToStatusIdStr = e['in_reply_to_status_id_str'] as String?;
    tweet.inReplyToUserIdStr = e['in_reply_to_user_id_str'] as String?;
    tweet.isQuoteStatus = e['is_quote_status'] as bool?;
    tweet.isTombstone = e['is_tombstone'] as bool?;
    tweet.lang = e['lang'] as String?;
    tweet.possiblySensitive = e['possibly_sensitive'] as bool?;
    tweet.quoteCount = e['quote_count'] as int?;
    tweet.quotedStatusIdStr = e['quoted_status_id_str'] as String?;
    tweet.quotedStatusPermalink =
        e['quoted_status_permalink'] == null ? null : QuotedStatusPermalink.fromJson(e['quoted_status_permalink']);
    tweet.replyCount = e['reply_count'] as int?;
    tweet.retweetCount = e['retweet_count'] as int?;
    tweet.retweeted = e['retweeted'] as bool?;
    tweet.source = e['source'] as String?;
    tweet.text = e['text'] ?? e['full_text'] as String?;
    tweet.user = user;

    tweet.retweetedStatus = retweetedStatus;
    tweet.retweetedStatusWithCard = retweetedStatus;
    tweet.quotedStatus = quotedStatus;
    tweet.quotedStatusWithCard = quotedStatus;

    tweet.displayTextRange = (e['display_text_range'] as List<dynamic>?)?.map((e) => e as int).toList();

    // TODO
    tweet.coordinates = null;
    tweet.truncated = null;
    tweet.place = null;
    tweet.possiblySensitiveAppealable = null;

    Entities copyEntities(Entities src, Entities trg) {
      if (src.media != null) {
        trg.media = src.media;
      }
      if (src.urls != null) {
        trg.urls = src.urls;
      }
      if (src.userMentions != null) {
        trg.userMentions = src.userMentions;
      }
      if (src.hashtags != null) {
        trg.hashtags = src.hashtags;
      }
      if (src.symbols != null) {
        trg.symbols = src.symbols;
      }
      if (src.polls != null) {
        trg.polls = src.polls;
      }
      return trg;
    }

    tweet.noteText = noteText;
    if (noteEntities != null) {
      tweet.entities = tweet.entities == null ? noteEntities : copyEntities(noteEntities, tweet.entities!);
      tweet.extendedEntities =
          tweet.extendedEntities == null ? noteEntities : copyEntities(noteEntities, tweet.extendedEntities!);
    }

    return tweet;
  }
}

class TweetChain {
  final String id;
  final List<TweetWithCard> tweets;
  final bool isPinned;

  TweetChain({required this.id, required this.tweets, required this.isPinned});

  factory TweetChain.fromJson(Map<String, dynamic> e) {
    var tweets = List.from(e['tweets']).map((e) => TweetWithCard.fromJson(e)).toList();

    return TweetChain(id: e['id'], tweets: tweets, isPinned: e['isPinned']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'tweets': tweets.map((e) => e.toJson()).toList(), 'isPinned': isPinned};
  }
}

class Follows {
  final int? cursorBottom;
  final int? cursorTop;
  final List<UserWithExtra> users;

  Follows({required this.cursorBottom, required this.cursorTop, required this.users});
}

class TweetStatus {
  // final TweetChain after;
  // final TweetChain before;
  final String? cursorBottom;
  final String? cursorTop;
  final List<TweetChain> chains;

  TweetStatus({required this.chains, required this.cursorBottom, required this.cursorTop});
}

class TwitterError {
  final String uri;
  final int code;
  final String message;

  TwitterError({required this.uri, required this.code, required this.message});

  @override
  String toString() {
    return 'TwitterError{code: $code, message: $message, url: $uri}';
  }
}

class UnknownTimelineItemType implements Exception {
  final String type;
  final String entryId;

  UnknownTimelineItemType(this.type, this.entryId);

  @override
  String toString() {
    return 'Unknown timeline item type: {type: $type, entryId: $entryId}';
  }
}

class WebFlowAuthModel extends ChangeNotifier {
  static final log = Logger('WebFlowAuthModel');

  WebFlowAuthModel(this.prefs) : super();
  final BasePrefService prefs;

  static http.Client client = http.Client();
  //static webFlowAuthModel =WebFlowAuthModel();
  static List<String> cookies = [];

  static Map<String, String>? _authHeader;
  static var _tokenLimit = -1;
  static var _tokenRemaining = -1;
  static var _expiresAt = -1;

  static var gtToken,
      flowToken1,
      flowToken2,
      flowTokenUserName,
      flowTokenPassword,
      flowToken2FA,
      auth_token,
      csrf_token;
  static var kdt_Coookie;

  static Future<PrefServiceShared> GetSharedPrefs() async {
    return await PrefServiceShared.init(prefix: 'pref_');
    // prefs = await SharedPreferences.getInstance();
  }

  Future<void> GetGuestId(Map<String, String> userAgentHeader) async {
    kdt_Coookie = await GetKdtCookie();
    if (kdt_Coookie != null) cookies.add(kdt_Coookie!);

    var request = http.Request("GET", Uri.parse('https://twitter.com/i/flow/login'))..followRedirects = false;
    request.headers.addAll(userAgentHeader);
    var response = await client.send(request);

    if (response.statusCode == 200) {
      var responseHeader = response.headers.toString();
      RegExpMatch? match = RegExp(r'(guest_id=.+?);').firstMatch(responseHeader);
      if (match != null) {
        var guest_id = match.group(1).toString();

        cookies.add(guest_id);
      } else {
        throw Exception("Guest ID not found in response headers");
      }
    } else {
      throw Exception("Return Status is (${response.statusCode}), it should be 302");
    }
  }

  Future<String?> GetGT(Map<String, String> userAgentHeader) async {
    var request = http.Request("Get", Uri.parse('https://twitter.com/i/flow/login'))..followRedirects = false;
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"Host": "twitter.com"});
    request.headers.addAll({"Cookie": cookies.join(";")});
    var response = await client.send(request);
    if (response.statusCode == 200) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      RegExpMatch? match = RegExp(r'(gt=(.+?));').firstMatch(stringData);
      gtToken = match?.group(2).toString();
      var gtToken_cookie = match?.group(1).toString();
      if (gtToken_cookie != null) {
        cookies.add(gtToken_cookie);
        return gtToken_cookie;
      }
    } else
      throw Exception("Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> GetFlowToken1(Map<String, String> userAgentHeader) async {
    Map<String, String> result = new Map<String, String>();
    var body = {
      "input_flow_data": {
        "flow_context": {
          "debug_overrides": {},
          "start_location": {"location": "manual_link"}
        }
      },
      "subtask_versions": {
        "action_list": 2,
        "alert_dialog": 1,
        "app_download_cta": 1,
        "check_logged_in_account": 1,
        "choice_selection": 3,
        "contacts_live_sync_permission_prompt": 0,
        "cta": 7,
        "email_verification": 2,
        "end_flow": 1,
        "enter_date": 1,
        "enter_email": 2,
        "enter_password": 5,
        "enter_phone": 2,
        "enter_recaptcha": 1,
        "enter_text": 5,
        "enter_username": 2,
        "generic_urt": 3,
        "in_app_notification": 1,
        "interest_picker": 3,
        "js_instrumentation": 1,
        "menu_dialog": 1,
        "notifications_permission_prompt": 2,
        "open_account": 2,
        "open_home_timeline": 1,
        "open_link": 1,
        "phone_verification": 4,
        "privacy_options": 1,
        "security_key": 3,
        "select_avatar": 4,
        "select_banner": 2,
        "settings_list": 7,
        "show_code": 1,
        "sign_up": 2,
        "sign_up_review": 4,
        "tweet_selection_urt": 1,
        "update_users": 1,
        "upload_media": 1,
        "user_recommendations_list": 4,
        "user_recommendations_urt": 1,
        "wait_spinner": 3,
        "web_modal": 1
      }
    };
    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json?flow_name=login'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);
    var response = await client.send(request);
    if (response.statusCode == 200) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      final exp = RegExp(r'flow_token":"(.+?)"');
      RegExpMatch? match = exp.firstMatch(stringData);
      flowToken1 = match!.group(1).toString();
      result.addAll({"flow_token1": flowToken1});
      var responseHeader = response.headers.toString();
      match = RegExp(r'(att=.+?);').firstMatch(responseHeader);
      var att = match!.group(1).toString();
      cookies.add(att);
    } else {
      final stringData = await response.stream.transform(utf8.decoder).join();
      throw Exception("Return Status is (${response.statusCode}), it should be 200, Message ${stringData}");
    }
  }

  Future<void> GetFlowToken2(Map<String, String> userAgentHeader) async {
    var body = {"flow_token": flowToken1, "subtask_inputs": []};
    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);
    var response = await client.send(request);
    if (response.statusCode == 200) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      final exp = RegExp(r'flow_token":"(.+?)"');
      RegExpMatch? match = exp.firstMatch(stringData);
      flowToken2 = match!.group(1).toString();
    } else
      throw Exception("Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> PassUsername(String username, String? email) async {
    var body = {
      "flow_token": flowToken2,
      "subtask_inputs": [
        {
          "subtask_id": "LoginEnterUserIdentifierSSO",
          "settings_list": {
            "setting_responses": [
              {
                "key": "user_identifier",
                "response_data": {
                  "text_data": {"result": username}
                }
              }
            ],
            "link": "next_link"
          }
        }
      ]
    };

    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);
    var response = await client.send(request);
    if (response.statusCode == 200) {
      String stringData = await response.stream.transform(utf8.decoder).join();
      final exp = RegExp(r'flow_token":"(.+?)"');
      RegExpMatch? match = exp.firstMatch(stringData);
      flowTokenUserName = match!.group(1).toString();
      if (stringData.contains("LoginEnterAlternateIdentifierSubtask")) {
        var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
        body = {
          "flow_token": flowTokenUserName,
          "subtask_inputs": [
            {
              "subtask_id": "LoginEnterAlternateIdentifierSubtask",
              "enter_text": {"text": email, "link": "next_link"}
            }
          ]
        };
        request.headers.addAll(userAgentHeader);
        request.headers.addAll({"content-type": "application/json"});
        request.headers.addAll({"authorization": bearerToken});
        request.headers.addAll({"x-guest-token": gtToken});
        request.headers.addAll({"Cookie": cookies.join(";")});
        request.headers.addAll({"Host": "api.twitter.com"});
        request.body = json.encode(body);
        var response = await client.send(request);
        if (response.statusCode == 200) {
          String stringData = await response.stream.transform(utf8.decoder).join();
          final exp = RegExp(r'flow_token":"(.+?)"');
          RegExpMatch? match = exp.firstMatch(stringData);
          flowTokenUserName = match!.group(1).toString();
        } else if (response.statusCode == 400) {
          final stringData = await response.stream.transform(utf8.decoder).join();
          if (stringData.contains("errors")) {
            var parsedError = json.decode(stringData);
            var errors = StringBuffer();
            for (var error in parsedError["errors"]) {
              errors.writeln(error["message"] ?? "null");
            }
            throw Exception(errors);
          }
        } else
          throw Exception("Return Status is (${response.statusCode}), it should be 200");
      }
    } else if (response.statusCode == 400) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      if (stringData.contains("errors")) {
        var parsedError = json.decode(stringData);
        var errors = StringBuffer();
        for (var error in parsedError["errors"]) {
          errors.writeln(error["message"] ?? "null");
        }
        throw Exception(errors);
      }
    } else
      throw Exception("Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> PassPassword(String password, Map<String, String> userAgentHeader) async {
    var body = {
      "flow_token": flowTokenUserName,
      "subtask_inputs": [
        {
          "subtask_id": "LoginEnterPassword",
          "enter_password": {"password": password, "link": "next_link"}
        }
      ]
    };
    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);
    var response = await client.send(request);
    if (response.statusCode == 200) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      final exp = RegExp(r'flow_token":"(.+?)"');
      RegExpMatch? match = exp.firstMatch(stringData);
      flowTokenPassword = match!.group(1).toString();
    } else if (response.statusCode == 400) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      if (stringData.contains("errors")) {
        var parsedError = json.decode(stringData);
        var errors = StringBuffer();
        for (var error in parsedError["errors"]) {
          errors.writeln(error["message"] ?? "null");
        }
        throw Exception(errors);
      }
    } else
      throw Exception("Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> Pass2FA(String authCode, Map<String, String> userAgentHeader) async {
    var body = {
      "flow_token": flowTokenPassword,
      "subtask_inputs": [
        {
          "subtask_id": "LoginTwoFactorAuthChallenge",
          "enter_text": {"text": authCode, "link": "next_link"}
        }
      ]
    };
    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);
    var response = await client.send(request);
    if (response.statusCode == 200) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      final exp = RegExp(r'flow_token":"(.+?)"');
      RegExpMatch? match = exp.firstMatch(stringData);
      flowToken2FA = match?.group(1).toString();
    } else if (response.statusCode == 400) {
      final stringData = await response.stream.transform(utf8.decoder).join();
      if (stringData.contains("errors")) {
        var parsedError = json.decode(stringData);
        var errors = StringBuffer();
        for (var error in parsedError["errors"]) {
          errors.writeln(error["message"] ?? "null");
        }
        throw Exception(errors);
      }
    } else
      throw Exception("2fa Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> GetAuthTokenCsrf(Map<String, String> userAgentHeader) async {
    var body = {
      "flow_token": flowTokenPassword,
      "subtask_inputs": [
        {
          "subtask_id": "AccountDuplicationCheck",
          "check_logged_in_account": {"link": "AccountDuplicationCheck_false"}
        }
      ]
    };
    var request = http.Request("Post", Uri.parse('https://api.twitter.com/1.1/onboarding/task.json'));
    request.headers.addAll(userAgentHeader);
    request.headers.addAll({"content-type": "application/json"});
    request.headers.addAll({"authorization": bearerToken});
    request.headers.addAll({"x-guest-token": gtToken});
    request.headers.addAll({"Cookie": cookies.join(";")});
    request.headers.addAll({"Host": "api.twitter.com"});
    request.body = json.encode(body);

    var response = await client.send(request);

    if (response.statusCode == 200) {
      var responseHeader = response.headers.toString();
      final expAuthToken = RegExp(r'(auth_token=(.+?));');
      RegExpMatch? matchAuthToken = expAuthToken.firstMatch(responseHeader);
      final String? auth_token = matchAuthToken?.group(2).toString();
      if (auth_token != null) {
        var auth_token_Coookie = matchAuthToken!.group(1).toString();
        cookies.add(auth_token_Coookie);
      }
      GetAuthTokenLimits(responseHeader);
      final expCt0 = RegExp(r'(ct0=(.+?));');
      RegExpMatch? matchCt0 = expCt0.firstMatch(responseHeader);
      csrf_token = matchCt0?.group(2).toString();
      if (csrf_token != null) {
        var csrf_token_Coookie = matchCt0!.group(1).toString();
        cookies.add(csrf_token_Coookie);
      }

      if (kdt_Coookie == null) {
        //extract KDT cookie to authenticate unknown device and prevent twitter
        // from sending email about New Login.
        final expKdt = RegExp(r'(kdt=(.+?));');
        RegExpMatch? matchKdt = expKdt.firstMatch(responseHeader);
        kdt_Coookie = matchKdt?.group(1).toString();
        if (kdt_Coookie != null) {
          await SetKdtCookie(kdt_Coookie);
        }
      }
      // final exptwid = RegExp(r'(twid="(.+?))"');
      // RegExpMatch? matchtwid = exptwid.firstMatch(responseHeader);
      // var twid_Coookie=matchtwid!.group(2).toString();
      // cookies.add("twid="+twid_Coookie);
    } else
      throw Exception("Return Status is (${response.statusCode}), it should be 200");
  }

  Future<void> BuildAuthHeader() async {
    _authHeader = Map<String, String>();
    _authHeader?.addAll({"Cookie": cookies.join(";")});
    _authHeader?.addAll({"authorization": bearerToken});
    _authHeader?.addAll({"x-csrf-token": csrf_token});
    await SetAuthHeader(_authHeader);
    //_authHeader!.addAll(userAgentHeader);
    //authHeader.addAll({"Host": "api.twitter.com"});
  }

  Future<bool> IsTokenExpired() async {
    if (_authHeader != null) {
      // If we don't have an expiry or limit, it's probably because we haven't made a request yet, so assume they're OK
      if (_expiresAt == -1 && _tokenLimit == -1 && _tokenRemaining == -1) {
        // TODO: Null safety with concurrent threads
        return true;
      }
      // Check if the token we have hasn't expired yet
      if (DateTime.now().millisecondsSinceEpoch < _expiresAt) {
        // Check if the token we have still has usages remaining
        if (_tokenRemaining < _tokenLimit) {
          // TODO: Null safety with concurrent threads
          return false;
        } else
          return false;
      }
      return false;
    } else
      return true;

    //log.info('Refreshing the Twitter token');
  }

  Future<void> getAuthTokenFromPref() async {
    if (_expiresAt == -1) _expiresAt = await GetTokenExpires();
    if (_tokenRemaining == -1) _tokenRemaining = await GetTokenRemaining();
    if (_tokenLimit == -1) _tokenLimit = await GetTokenLimit();
    if (_authHeader == null) {
      _authHeader = await GetAuthHeaderPref();
    }
  }

  Future<void> GetAuthTokenLimits(
    String responseHeader,
  ) async {
    // Update our token's rate limit counters
    final expAuthTokenLimitReset = RegExp(r'(x-rate-limit-reset:(.+?)),');
    RegExpMatch? matchAuthTokenLimitReset = expAuthTokenLimitReset.firstMatch(responseHeader);
    var limitReset = matchAuthTokenLimitReset?.group(2).toString();

    final expAuthTokenLimitRemaining = RegExp(r'(x-rate-limit-remaining:(.+?)),');
    RegExpMatch? matchAuthTokenLimitRemaining = expAuthTokenLimitRemaining.firstMatch(responseHeader);
    var limitRemaining = matchAuthTokenLimitRemaining?.group(2).toString();

    final expAuthTokenLimitLimit = RegExp(r'(x-rate-limit-limit:(.+?)),');
    RegExpMatch? matchAuthTokenLimitLimit = expAuthTokenLimitLimit.firstMatch(responseHeader);
    var limitLimit = matchAuthTokenLimitLimit?.group(2).toString();

    if (limitReset != null && limitRemaining != null && _tokenLimit != null) {
      _expiresAt = int.parse(limitReset) * 1000;
      _tokenRemaining = int.parse(limitRemaining);
      _tokenLimit = int.parse(limitLimit!);

      await SetTokenExpires(_expiresAt);
      await SetTokenExpires(_tokenRemaining);
      await SetTokenExpires(_tokenLimit);
    }
  }

  Future<Map<dynamic, dynamic>?> GetAuthHeader(
      {required String username, required String password, String? email, BuildContext? context}) async {
    try {
      if (_authHeader == null) await getAuthTokenFromPref();
      if (!await IsTokenExpired() && _authHeader != null) return _authHeader!;
      await GetGuestId(userAgentHeader);
      await GetGT(userAgentHeader);
      await GetFlowToken1(userAgentHeader);
      await GetFlowToken2(userAgentHeader);
      await PassUsername(username, email);
      await PassPassword(password, userAgentHeader);
      //if (authCode != null) await Pass2FA(authCode.toString(), userAgentHeader);
      await GetAuthTokenCsrf(userAgentHeader);
      await BuildAuthHeader();
    } on Exception catch (e) {
      this.DeleteAllCookies();
      throw Exception(e);
    }

    if (_authHeader != null) {
      return _authHeader!;
    }
  }

  Future DeleteAllCookies() async {
    this.DeleteAuthHeader();
    this.DeleteTokenExpires();
    this.DeleteTokenLimit();
    this.DeleteTokenRemaining();
    _authHeader = null;
    _expiresAt = -1;
    _tokenLimit = -1;
    _tokenRemaining = -1;
    cookies.clear();
  }

  Future SetKdtCookie(String cookie) async {
    await prefs.set("KDT_Cookie", cookie);
  }

  Future<String?> GetKdtCookie() async {
    return prefs.get("KDT_Cookie");
  }

  Future DeleteKdtCookie() async {
    return prefs.remove("KDT_Cookie");
  }

  Future SetAuthHeader(Map<String, String>? header) async {
    await prefs.set("auth_header", json.encode(header));
  }

  Future<Map<String, String>?> GetAuthHeaderPref() async {
    var authHeader = await prefs.get("auth_header") ?? null;
    if (authHeader != null) {
      return Map.castFrom<String, dynamic, String, String>(json.decode(authHeader));
    } else
      return null;
  }

  Future DeleteAuthHeader() async {
    await prefs.remove("auth_header");
  }

  Future SetTokenExpires(int expiresAt) async {
    await prefs.set("auth_expiresAt", expiresAt);
  }

  Future<int> GetTokenExpires() async {
    return prefs.get("auth_expiresAt") ?? -1;
  }

  Future DeleteTokenExpires() async {
    return prefs.remove("auth_expiresAt");
  }

  Future SetTokenRemaining(int tokenRemaining) async {
    await prefs.set("auth_tokenRemaining", tokenRemaining);
  }

  Future<int> GetTokenRemaining() async {
    return prefs.get("auth_tokenRemaining") ?? -1;
  }

  Future DeleteTokenRemaining() async {
    return prefs.remove("auth_tokenRemaining");
  }

  Future SetTokenLimit(int tokenLimit) async {
    await prefs.set("auth_tokenLimit", tokenLimit);
  }

  Future<int> GetTokenLimit() async {
    return prefs.get("auth_tokenLimit") ?? -1;
  }

  Future DeleteTokenLimit() async {
    return prefs.remove("auth_tokenLimit");
  }

  // log.info('Imported data into ${}');
}
