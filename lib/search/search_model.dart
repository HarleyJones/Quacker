import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/user.dart';

class SearchTweetsModel extends Store<List<TweetWithCard>> {
  SearchTweetsModel() : super([]);

  Future<void> searchTweets(String query, String product) async {
    await execute(() async {
      if (query.isEmpty) {
        return [];
      } else {
        // TODO: Is this right?
        return (await Twitter.searchTweets(query, true, product: product))
            .chains
            .map((e) => e.tweets)
            .expand((element) => element)
            .toList();
      }
    });
  }
}

class SearchUsersModel extends Store<List<UserWithExtra>> {
  SearchUsersModel() : super([]);

  Future<void> searchUsers(String query, BuildContext context) async {
    await execute(() async {
      if (query.isEmpty) {
        return [];
      } else if (query[0] == '@' && query.split(" ").last.isNotEmpty) {
        return [
          UserWithExtra.fromJson({
            "id_str": "GOTOPROFILE",
            "name": query.substring(1),
            "screen_name": query.substring(1),
            "verified": false,
            "created_at": "Sat Jan 01 12:00:00 +0000 2022",
          })
        ];
      } else {
        return await Twitter.searchUsers(query);
      }
    });
  }
}
