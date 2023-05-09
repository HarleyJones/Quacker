import 'package:flutter/material.dart';
import 'package:Quacker/constants.dart';
import 'package:Quacker/generated/l10n.dart';
import 'package:Quacker/home/home_screen.dart';
import 'package:Quacker/subscriptions/_list.dart';
import 'package:Quacker/subscriptions/users_model.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.current.subscriptions),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () => Navigator.pushNamed(context, routeSubscriptionsImport),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SubscriptionsModel>().refreshSubscriptionData(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
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
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: () => context.read<SubscriptionsModel>().toggleOrderSubscriptionsAscending(),
          ),
          ...createCommonAppBarActions(context)
        ],
      ),
      body: const SubscriptionUsers(),
    );
  }
}
