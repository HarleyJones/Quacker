import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:Quacker/constants.dart';
import 'package:Quacker/generated/l10n.dart';
import 'package:Quacker/group/group_screen.dart';
import 'package:Quacker/home/_groups.dart';
import 'package:Quacker/home/_missing.dart';
import 'package:Quacker/home/_saved.dart';
import 'package:Quacker/home/home_model.dart';
import 'package:Quacker/search/search.dart';
import 'package:Quacker/subscriptions/subscriptions.dart';
import 'package:Quacker/trends/trends.dart';
import 'package:Quacker/ui/errors.dart';
import 'package:Quacker/ui/physics.dart';
import 'package:Quacker/utils/debounce.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:scroll_bottom_navigation_bar/scroll_bottom_navigation_bar.dart';

typedef NavigationTitleBuilder = String Function(BuildContext context);

class NavigationPage {
  final String id;
  final NavigationTitleBuilder titleBuilder;
  final IconData icon;

  NavigationPage(this.id, this.titleBuilder, this.icon);
}

List<Widget> createCommonAppBarActions(BuildContext context) {
  return [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () => Navigator.pushNamed(context, routeSearch, arguments: SearchArguments(focusInputOnOpen: true)),
    ),
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.pushNamed(context, routeSettings);
      },
    )
  ];
}

final List<NavigationPage> defaultHomePages = [
  NavigationPage('subscriptions', (c) => L10n.of(c).subscriptions, Icons.subscriptions),
  NavigationPage('groups', (c) => L10n.of(c).groups, Icons.group),
  NavigationPage('trending', (c) => L10n.of(c).trending, Icons.trending_up),
  NavigationPage('saved', (c) => L10n.of(c).saved, Icons.bookmark),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var prefs = PrefService.of(context);
    var model = context.read<HomeModel>();

    return _HomeScreen(prefs: prefs, model: model);
  }
}

class _HomeScreen extends StatefulWidget {
  final BasePrefService prefs;
  final HomeModel model;

  const _HomeScreen({Key? key, required this.prefs, required this.model}) : super(key: key);

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _initialPage = 0;
  List<NavigationPage> _pages = [];

  @override
  void initState() {
    super.initState();

    _buildPages(widget.model.state);
    widget.model.observer(onState: _buildPages);
  }

  void _buildPages(List<HomePage> state) {
    var pages = state.where((element) => element.selected).map((e) => e.page).toList();

    if (widget.prefs.getKeys().contains(optionHomeInitialTab)) {
      _initialPage = max(0, pages.indexWhere((element) => element.id == widget.prefs.get(optionHomeInitialTab)));
    }

    setState(() {
      _pages = pages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<HomeModel, Object, List<HomePage>>.transition(
        store: widget.model,
        onError: (_, e) => ScaffoldErrorWidget(
              prefix: L10n.current.unable_to_load_home_pages,
              error: e,
              stackTrace: null,
              onRetry: () async => await widget.model.resetPages(),
              retryText: L10n.current.reset_home_pages,
            ),
        onLoading: (_) => const Center(child: CircularProgressIndicator()),
        onState: (_, state) {
          return ScaffoldWithBottomNavigation(
              pages: _pages,
              initialPage: _initialPage,
              builder: (scrollController) {
                return [
                  ..._pages.map((e) {
                    if (e.id.startsWith('group-')) {
                      return SubscriptionGroupScreen(
                          scrollController: scrollController,
                          id: e.id.replaceAll('group-', ''),
                          actions: createCommonAppBarActions(context));
                    }

                    switch (e.id) {
                      case 'subscriptions':
                        return const SubscriptionsScreen();
                      case 'groups':
                        return GroupsScreen(scrollController: scrollController);
                      case 'trending':
                        return TrendsScreen(scrollController: scrollController);
                      case 'saved':
                        return SavedScreen(scrollController: scrollController);
                      default:
                        return const MissingScreen();
                    }
                  })
                ];
              });
        });
  }
}

class ScaffoldWithBottomNavigation extends StatefulWidget {
  final List<NavigationPage> pages;
  final int initialPage;
  final List<Widget> Function(ScrollController scrollController) builder;

  const ScaffoldWithBottomNavigation({Key? key, required this.pages, required this.initialPage, required this.builder})
      : super(key: key);

  @override
  State<ScaffoldWithBottomNavigation> createState() => _ScaffoldWithBottomNavigationState();
}

class _ScaffoldWithBottomNavigationState extends State<ScaffoldWithBottomNavigation> {
  final ScrollController scrollController = ScrollController();

  PageController? _pageController;
  late List<Widget> _children;
  late List<NavigationPage> _pages;

  @override
  void initState() {
    super.initState();

    _pages = _padToMinimumPagesLength(widget.pages);

    _pageController = PageController(initialPage: widget.initialPage);

    scrollController.bottomNavigationBar.setTab(widget.initialPage);
    scrollController.bottomNavigationBar.tabListener((index) {
      _pageController?.animateToPage(index, curve: Curves.easeInOut, duration: const Duration(milliseconds: 100));
    });

    _children = widget.builder(scrollController);
  }

  List<NavigationPage> _padToMinimumPagesLength(List<NavigationPage> pages) {
    var widgetPages = pages;
    if (widgetPages.length < 2) {
      widgetPages.addAll(List.generate(2 - widgetPages.length, (index) {
        return NavigationPage('none', (context) => L10n.current.missing_page, Icons.disabled_by_default);
      }));
    }

    return widgetPages;
  }

  @override
  void didUpdateWidget(ScaffoldWithBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    var newPages = _padToMinimumPagesLength(widget.pages);
    if (oldWidget.pages != widget.pages) {
      setState(() {
        _children = widget.builder(scrollController);
        _pages = newPages;
      });
    }

    var page = _pageController?.page?.toInt();
    if (page != null) {
      // Ensure we're not trying to show a page that no longer exists (i.e. one that was selected, but now deleted)
      var currentTab = scrollController.bottomNavigationBar.tabNotifier.value;
      if (currentTab >= newPages.length) {
        scrollController.bottomNavigationBar.tabNotifier.value = newPages.length - 1;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const LessSensitiveScrollPhysics(),
        onPageChanged: (page) => Debouncer.debounce('page-change', const Duration(milliseconds: 200), () {
          // Reset the height when the page changes, otherwise the navigation bar stays hidden forever
          scrollController.bottomNavigationBar.heightNotifier.value = 1;
          scrollController.bottomNavigationBar.setTab(page);
        }),
        children: _children,
      ),
      bottomNavigationBar: ScrollBottomNavigationBar(
        controller: scrollController,
        showUnselectedLabels: true,
        items: [
          ..._pages.map((e) => BottomNavigationBarItem(icon: Icon(e.icon, size: 22), label: e.titleBuilder(context)))
        ],
      ),
    );
  }
}
