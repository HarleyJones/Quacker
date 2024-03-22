import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:quacker/forYou.dart';
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
  dynamic _tabValue = L10n.current.following;

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

    return Provider<GroupModel>(create: (context) {
      var model = GroupModel(widget.id);
      model.loadGroup();

      return model;
    }, builder: (context, child) {
      var model = context.read<GroupModel>();

      return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: false,
                snap: true,
                floating: true,
                title: DropdownButton(
                    padding: EdgeInsets.only(left: 8),
                    underline: Container(),
                    value: _tabValue,
                    onChanged: (value) => setState(() {
                          if (value == L10n.current.foryou) {
                            _tab = 1;
                          } else if (value == L10n.current.following) {
                            _tab = 0;
                          }
                          _tabValue = value;
                        }),
                    items: [
                      DropdownMenuItem(value: L10n.current.following, child: Text(L10n.current.following)),
                      DropdownMenuItem(value: L10n.current.foryou, child: Text(L10n.current.foryou))
                    ]),
                actions: _tab == 1
                    ? [...createCommonAppBarActions(context)]
                    : [
                        IconButton(
                            icon: const Icon(Icons.more_vert), onPressed: () => showFeedSettings(context, model)),
                        IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              await model.loadGroup();
                            }),
                        ...createCommonAppBarActions(context)
                      ],
              ),
            ];
          },
          body: [
            SubscriptionGroupScreenContent(
              id: widget.id,
            ),
            forYouTweets,
          ][_tab]);
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
