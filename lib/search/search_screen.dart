import 'package:flutter/material.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/trends/_list.dart';
import 'package:quacker/trends/_settings.dart';
import 'package:quacker/trends/_tabs.dart';

class SearchScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SearchScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.search), bottom: TrendsTabBar()),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async => showDialog(
                context: context,
                builder: (context) => const TrendsSettings(),
              )),
      body: TrendsList(scrollController: widget.scrollController),
    );
  }
}
