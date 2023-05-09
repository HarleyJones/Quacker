import 'package:flutter_triple/flutter_triple.dart';
import 'package:Quacker/client.dart';
import 'package:Quacker/user.dart';

class SearchUsersModel extends StreamStore<Object, List<UserWithExtra>> {
  SearchUsersModel() : super([]);

  Future<void> searchUsers(String query) async {
    await execute(() async {
      if (query.isEmpty) {
        return [];
      } else {
        return await Twitter.searchUsers(query);
      }
    });
  }
}
