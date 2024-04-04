import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/database/entities.dart';
import 'package:quacker/forYou.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/profile/profile.dart';
import 'package:quacker/search/search.dart';
import 'package:quacker/search/search_model.dart';
import 'package:quacker/subscriptions/users_model.dart';
import 'package:quacker/trends/_list.dart';
import 'package:quacker/trends/_settings.dart';
import 'package:quacker/tweet/_video.dart';
import 'package:quacker/tweet/tweet.dart';
import 'package:quacker/ui/errors.dart';
import 'package:quacker/user.dart';
import 'package:quacker/utils/notifiers.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  final ScrollController scrollController;

  const ExploreScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late TabController _tabController;
  late CombinedChangeNotifier _bothControllers;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _bothControllers = CombinedChangeNotifier(_tabController, _queryController);
  }

  @override
  Widget build(BuildContext context) {
    var subscriptionsModel = context.read<SubscriptionsModel>();

    var prefs = PrefService.of(context, listen: false);

    var defaultTheme = Theme.of(context);
    var searchTheme = defaultTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: defaultTheme.colorScheme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        iconTheme: defaultTheme.primaryIconTheme.copyWith(color: Colors.grey),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );

    return Theme(
      data: searchTheme,
      child: Scaffold(
        // Needed as we're nesting Scaffolds, which causes Flutter to calculate keyboard height incorrectly
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            forceMaterialTransparency: true,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(8, 36, 8, 4),
              child: SearchBar(
                onTap: () =>
                    Navigator.pushNamed(context, routeSearch, arguments: SearchArguments(0, focusInputOnOpen: true)),
                leading: const Icon(Icons.search),
              ),
            )),
        body: Column(
          children: [
            Material(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: TabBar(
                controller: _tabController,
                onTap: (int value) => setState(() {}),
                tabs: [
                  Tab(text: L10n.of(context).foryou),
                  Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(L10n.of(context).trending),
                      IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () async => showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    const Padding(padding: EdgeInsets.all(8.0), child: TrendsSettings()),
                              ))
                    ]),
                  ),
                ],
                labelColor: Theme.of(context).appBarTheme.foregroundColor,
                indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            MultiProvider(
              providers: [
                ChangeNotifierProvider<TweetContextState>(
                    create: (_) => TweetContextState(prefs.get(optionTweetsHideSensitive))),
                ChangeNotifierProvider<VideoContextState>(
                    create: (_) => VideoContextState(prefs.get(optionMediaDefaultMute))),
              ],
              child: Expanded(
                  child: [
                ForYouTweets(type: 'profile', includeReplies: false, pinnedTweets: [], pref: PrefService.of(context)),
                TrendsList(
                  scrollController: ScrollController(),
                ),
              ][_tabController.index]),
            )
          ],
        ),
      ),
    );
  }
}

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class TweetSearchResultList<S extends Store<List<T>>, T> extends StatefulWidget {
  final TextEditingController queryController;
  final S store;
  final Future<void> Function(String query) searchFunction;
  final ItemWidgetBuilder<T> itemBuilder;

  const TweetSearchResultList(
      {Key? key,
      required this.queryController,
      required this.store,
      required this.searchFunction,
      required this.itemBuilder})
      : super(key: key);

  @override
  State<TweetSearchResultList<S, T>> createState() => _TweetSearchResultListState<S, T>();
}

class _TweetSearchResultListState<S extends Store<List<T>>, T> extends State<TweetSearchResultList<S, T>> {
  Timer? _debounce;
  String? _previousQuery = '';

  @override
  void initState() {
    super.initState();

    widget.queryController.addListener(() {
      var query = widget.queryController.text;
      if (query == _previousQuery) {
        return;
      }

      // If the current query is different from the last render's query, search
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }

      // Debounce the search, so we don't make a request per keystroke
      _debounce = Timer(const Duration(milliseconds: 750), () async {
        fetchResults();
      });
    });

    fetchResults();
  }

  void fetchResults() {
    if (mounted) {
      var query = widget.queryController.text;
      _previousQuery = query;
      widget.searchFunction(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<S, List<T>>.transition(
      store: widget.store,
      onLoading: (_) => const Center(child: CircularProgressIndicator()),
      onError: (_, error) => FullPageErrorWidget(
        error: error,
        stackTrace: null,
        prefix: L10n.of(context).unable_to_load_the_search_results,
        onRetry: () => fetchResults(),
      ),
      onState: (_, items) {
        if (items.isEmpty) {
          return Center(child: Text(L10n.of(context).no_results));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, items[index]);
          },
        );
      },
    );
  }
}
