import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:quacker/forYou/_tweets.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/group/_settings.dart';
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

  late TabController _tabController;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animation!.addListener(_tabListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => print("hi"));
  }

  void _tabListener() {
    if (_tab != _tabController.animation!.value.round()) {
      setState(() {
        _tab = _tabController.animation!.value.round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user.idStr = "1";
    user.possiblySensitive = false;
    user.screenName = "ForYou";

    dynamic forYouTweets = ForYouTweets(
        user: user, type: 'profile', includeReplies: false, pinnedTweets: [], pref: PrefService.of(context));

    return Scaffold(
        body: Provider<GroupModel>(create: (context) {
      var model = GroupModel(widget.id);
      model.loadGroup();

      return model;
    }, builder: (context, child) {
      var model = context.read<GroupModel>();

      return Scaffold(
          appBar: AppBar(
              title: Text(L10n.current.feed),
              actions: _tab == 0
                  ? [...createCommonAppBarActions(context)]
                  : [
                      IconButton(icon: const Icon(Icons.more_vert), onPressed: () => showFeedSettings(context, model)),
                      IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () async {
                            await model.loadGroup();
                          }),
                      ...createCommonAppBarActions(context)
                    ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [Tab(child: Text(L10n.current.foryou)), Tab(child: Text(L10n.current.following))],
              )),
          body: TabBarView(controller: _tabController, children: [
            forYouTweets,
            SubscriptionGroupScreenContent(
              id: widget.id,
            ),
          ]));
    }));
  }
}
