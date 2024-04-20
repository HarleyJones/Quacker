import 'package:flutter_triple/flutter_triple.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/user.dart';

class SearchTweetsModel extends Store<SearchStatus<TweetWithCard>> {
  SearchTweetsModel() : super(SearchStatus(items: []));

  Future<void> searchTweets(String query, {bool trending = false, String? cursor}) async {
    await execute(() async {
      if (query.isEmpty) {
        return SearchStatus(items: []);
      } else {
        TweetStatus ts = await Twitter.searchTweetsGraphql(query, true, trending: trending, cursor: cursor);
        return SearchStatus(
            items: ts.chains.map((e) => e.tweets).expand((e) => e).toList(), cursorBottom: ts.cursorBottom);
      }
    });
  }
}

class SearchUsersModel extends Store<SearchStatus<UserWithExtra>> {
  SearchUsersModel() : super(SearchStatus(items: []));

  Future<void> searchUsers(String query, {String? cursor}) async {
    await execute(() async {
      if (query.isEmpty) {
        return SearchStatus(items: []);
      } else {
        return await Twitter.searchUsersGraphql(query, limit: 100, cursor: cursor);
      }
    });
  }
}
