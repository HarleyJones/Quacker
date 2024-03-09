import 'package:flutter/material.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/group/group_model.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/subscriptions/_groups.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
  final ScrollController scrollController;

  const GroupsScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: false,
            snap: true,
            floating: true,
            title: Text(L10n.current.groups),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'name',
                    child: Text(L10n.of(context).name),
                  ),
                  PopupMenuItem(
                    value: 'created_at',
                    child: Text(L10n.of(context).date_created),
                  ),
                ],
                onSelected: (value) => context.read<GroupsModel>().changeOrderSubscriptionGroupsBy(value),
              ),
              IconButton(
                icon: const Icon(Icons.sort_by_alpha_rounded),
                onPressed: () => context.read<GroupsModel>().toggleOrderSubscriptionGroupsAscending(),
              ),
              ...createCommonAppBarActions(context),
            ],
          )
        ];
      },
      body: SubscriptionGroups(scrollController: scrollController),
    ));
  }
}
