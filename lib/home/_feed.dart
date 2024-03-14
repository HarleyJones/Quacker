import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:quacker/forYou/_tweets.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/group/group_model.dart';
import 'package:quacker/group/group_screen.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/user.dart';

class FeedScreen extends StatefulWidget {
  final ScrollController scrollController;
  final String id;
  final String name;

  const FeedScreen({Key? key, required this.scrollController, required this.id, required this.name}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin<FeedScreen>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  UserWithExtra user = UserWithExtra();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user.idStr = "1";
    user.possiblySensitive = false;
    user.screenName = "ForYou";

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: Text(L10n.current.feed),
                bottom: TabBar(
                  tabs: [Tab(child: Text(L10n.current.foryou)), Tab(child: Text(L10n.current.following))],
                )),
            body: TabBarView(
              children: [
                ForYouTweets(
                    user: user,
                    type: 'profile',
                    includeReplies: false,
                    pinnedTweets: [],
                    pref: PrefService.of(context)),
                Provider<GroupModel>(create: (context) {
                  var model = GroupModel(widget.id);
                  model.loadGroup();

                  return model;
                }, builder: (context, child) {
                  return SubscriptionGroupScreenContent(
                    id: widget.id,
                  );
                })
              ],
            )));
  }
}
