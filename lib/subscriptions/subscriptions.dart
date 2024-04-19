import 'package:flutter/material.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:quacker/group/group_model.dart';
import 'package:quacker/home/home_screen.dart';
import 'package:quacker/subscriptions/_groups.dart';
import 'package:quacker/subscriptions/_import.dart';
import 'package:quacker/subscriptions/_list.dart';
import 'package:quacker/subscriptions/users_model.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  final ScrollController scrollController;

  const SubscriptionsScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.subscriptions), actions: createCommonAppBarActions(context)),
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            controller: scrollController,
            children: [
              ExpansionTile(
                title: Text(
                  L10n.of(context).groups,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                enabled: false,
                initiallyExpanded: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.sort,
                        color: Theme.of(context).iconTheme.color,
                      ),
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
                      icon: Icon(
                        Icons.sort_by_alpha,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => context.read<GroupsModel>().toggleOrderSubscriptionGroupsAscending(),
                    ),
                  ],
                ),
                children: [
                  SubscriptionGroups(
                    scrollController: scrollController,
                  ),
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              ExpansionTile(
                title: Text(
                  L10n.of(context).subscriptions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                enabled: false,
                initiallyExpanded: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => context.read<SubscriptionsModel>().refreshSubscriptionData(),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.sort,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'name',
                          child: Text(L10n.of(context).name),
                        ),
                        PopupMenuItem(
                          value: 'screen_name',
                          child: Text(L10n.of(context).username),
                        ),
                        PopupMenuItem(
                          value: 'created_at',
                          child: Text(L10n.of(context).date_subscribed),
                        ),
                      ],
                      onSelected: (value) => context.read<SubscriptionsModel>().changeOrderSubscriptionsBy(value),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.sort_by_alpha,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => context.read<SubscriptionsModel>().toggleOrderSubscriptionsAscending(),
                    ),
                  ],
                ),
                children: [
                  SubscriptionUsers(
                    scrollController: scrollController,
                  )
                ],
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cloud_download),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const SubscriptionImportScreen(),
        ),
      ),
    );
  }
}
