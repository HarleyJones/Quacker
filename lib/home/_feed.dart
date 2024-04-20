import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:quacker/constants.dart';
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

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin<FeedScreen> {
  @override
  bool get wantKeepAlive => true;

  UserWithExtra user = UserWithExtra();
  Duration animationDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool _disableAnimations = PrefService.of(context).get(optionDisableAnimations) == true;

    user.idStr = "1";
    user.possiblySensitive = false;
    user.screenName = "ForYou";

    return Provider<GroupModel>(create: (context) {
      var model = GroupModel(widget.id);
      model.loadGroup();

      return model;
    }, builder: (context, child) {
      var model = context.read<GroupModel>();

      return NestedScrollView(
          controller: widget.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(pinned: false, snap: true, floating: true, title: Text(L10n.of(context).feed), actions: [
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () => showFeedSettings(context, model)),
                IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () async {
                      if (_disableAnimations == false) {
                        await widget.scrollController
                            .animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                      } else {
                        widget.scrollController.jumpTo(0);
                      }
                    }),
                IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await model.loadGroup();
                    }),
                ...createCommonAppBarActions(context)
              ]),
            ];
          },
          body: SubscriptionGroupScreenContent(
            id: widget.id,
          ));
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
