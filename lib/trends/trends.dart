import 'package:flutter/material.dart';
import 'package:quacker/constants.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/search/search.dart';
import 'package:quacker/trends/_list.dart';
import 'package:quacker/trends/_settings.dart';
import 'package:quacker/trends/_tabs.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({Key? key}) : super(key: key);

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> with AutomaticKeepAliveClientMixin<TrendsScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 36.0, 8.0, 8.0),
              child: SearchBar(
                controller: _searchController,
                hintText: L10n.of(context).search,
                leading: Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.search)),
                onSubmitted: (value) {
                  Navigator.pushNamed(context, routeSearch,
                      arguments: SearchArguments(0,
                          focusInputOnOpen: false, query: Uri.decodeQueryComponent(_searchController.text)));
                  _searchController.clear();
                },
              )),
          bottom: const TrendsTabBar()),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async => showModalBottomSheet(
                context: context,
                builder: (context) => const TrendsSettings(),
              )),
      body: TrendsList(),
    );
  }
}
