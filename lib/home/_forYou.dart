import 'package:flutter/material.dart';
import 'package:quacker/client/client.dart';
import 'package:quacker/profile/profile.dart';
import 'package:quacker/tweet/conversation.dart';
import 'package:quacker/ui/errors.dart';
import 'package:quacker/user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:quacker/generated/l10n.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

final UserWithExtra user = UserWithExtra();

class ForYouTweets extends StatefulWidget {
  final PagingController<String?, TweetChain> pagingController;
  final String type;
  final bool includeReplies;
  final List<String> pinnedTweets;
  final BasePrefService pref;

  const ForYouTweets(this.pagingController,
      {Key? key, required this.type, required this.includeReplies, required this.pinnedTweets, required this.pref})
      : super(key: key);

  @override
  State<ForYouTweets> createState() => _ForYouTweetsState();
}

class _ForYouTweetsState extends State<ForYouTweets> with AutomaticKeepAliveClientMixin<ForYouTweets> {
  static const int pageSize = 20;
  int loadTweetsCounter = 0;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    user.idStr = "1";
    user.possiblySensitive = false;
    user.screenName = "ForYou";

    widget.pagingController.addPageRequestListener((cursor) {
      _loadTweets(cursor);
    });
  }

  @override
  void dispose() {
    widget.pagingController.dispose();
    super.dispose();
  }

  void incrementLoadTweetsCounter() {
    ++loadTweetsCounter;
  }

  int getLoadTweetsCounter() {
    return loadTweetsCounter;
  }

  Future _loadTweets(String? cursor) async {
    try {
      var result = await Twitter.getTimelineTweets(
        user.idStr!,
        widget.type,
        widget.pinnedTweets,
        cursor: cursor,
        count: pageSize,
        includeReplies: widget.includeReplies,
        getTweetsCounter: getLoadTweetsCounter,
        incrementTweetsCounter: incrementLoadTweetsCounter,
      );

      if (!mounted) {
        return;
      }

      if (result.cursorBottom == widget.pagingController.nextPageKey) {
        widget.pagingController.appendLastPage([]);
      } else {
        widget.pagingController.appendPage(result.chains, result.cursorBottom);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        widget.pagingController.error = [e, stackTrace];
      }
    }
  }

  void refresh() async {
    widget.pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<TweetContextState>(
              create: (_) => TweetContextState(PrefService.of(context).get(optionTweetsHideSensitive)))
        ],
        builder: (context, child) {
          return Consumer<TweetContextState>(builder: (context, model, child) {
            if (model.hideSensitive && (user.possiblySensitive ?? false)) {
              return EmojiErrorWidget(
                emoji: '🍆🙈🍆',
                message: L10n.current.possibly_sensitive,
                errorMessage: L10n.current.possibly_sensitive_profile,
                onRetry: () async => model.setHideSensitive(false),
                retryText: L10n.current.yes_please,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => refresh(),
              child: PagedListView<String?, TweetChain>(
                padding: const EdgeInsets.only(top: 4),
                pagingController: widget.pagingController,
                addAutomaticKeepAlives: false,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, chain, index) {
                    return TweetConversation(
                        id: chain.id, tweets: chain.tweets, username: user.screenName!, isPinned: chain.isPinned);
                  },
                  firstPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
                    error: widget.pagingController.error[0],
                    stackTrace: widget.pagingController.error[1],
                    prefix: L10n.of(context).unable_to_load_the_tweets,
                    onRetry: () => _loadTweets(widget.pagingController.firstPageKey),
                  ),
                  newPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
                    error: widget.pagingController.error[0],
                    stackTrace: widget.pagingController.error[1],
                    prefix: L10n.of(context).unable_to_load_the_next_page_of_tweets,
                    onRetry: () => _loadTweets(widget.pagingController.nextPageKey),
                  ),
                  noItemsFoundIndicatorBuilder: (context) {
                    return Center(
                      child: Text(
                        L10n.of(context).unable_to_load_the_tweets_for_the_feed,
                      ),
                    );
                  },
                ),
              ),
            );
          });
        });
  }
}
