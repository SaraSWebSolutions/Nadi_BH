import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/Chats_List_Provider.dart';
import 'package:nadi_user_app/providers/connectivity_provider.dart';
import 'package:nadi_user_app/providers/stream_unread_provider.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/no_internet_widget.dart';

class ChatsView extends ConsumerStatefulWidget {
  const ChatsView({super.key});

  @override
  ConsumerState<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends ConsumerState<ChatsView> {
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(fetchchatslistprovider);
    });
  }

  Future<void> _refreshChats() async {
    ref.invalidate(fetchchatslistprovider);
    ref.invalidate(streamUnreadCountsProvider);
    await ref.read(fetchchatslistprovider.future);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatlist = ref.watch(fetchchatslistprovider);
    final unreadCounts = ref.watch(streamUnreadCountsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          loc.chats,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),

        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 38,
              height: 38,
              child: FittedBox(
                child: AppCircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: connectivity.when(
        data: (isOnline) {
          if (!isOnline) return const NoInternetScreen();

          return Column(
            children: [
              const SizedBox(height: 10),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: TextField(
                    showCursor: true,
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchText = value);
                    },
                    decoration: InputDecoration(
                      hintText: loc.searchMessage,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              /// CHAT LIST
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.app_background_clr,
                  onRefresh: _refreshChats,
                  child: chatlist.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text(err.toString())),
                      ],
                    ),
                    data: (chatModel) {
                      final chats = chatModel.data;

                      final q = searchText.toLowerCase();
                      final filteredChats = chats.where((user) {
                        final name = user.name?.toLowerCase() ?? "";
                        final role = user.roleName?.toLowerCase() ?? "";
                        return q.isEmpty ||
                            name.contains(q) ||
                            role.contains(q);
                      }).toList();

                      if (filteredChats.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(loc.noChatsFound)),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final user = filteredChats[index];

                          // StreamProvider value — auto-updates on new messages
                          final unread = unreadCounts.value?[user.id] ?? 0;

                          final hasUnread = unread > 0;
                          final theme = Theme.of(context);

                          return InkWell(
                            onTap: () {
                              context
                                  .push(
                                    "/chatDetails",
                                    extra: {
                                      "id": user.id,
                                      "name": user.name,
                                      "roleName": user.roleName,
                                    },
                                  )
                                  .then((_) {
                                    ref.invalidate(streamUnreadCountsProvider);
                                    ref.invalidate(fetchchatslistprovider);
                                  });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: hasUnread
                                    ? AppColors.app_background_clr.withValues(
                                        alpha: 0.04,
                                      )
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.12),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /// AVATAR
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor:
                                            AppColors.app_background_clr,
                                        child: Text(
                                          (user.name?.isNotEmpty ?? false)
                                              ? user.name![0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      /// Online-style dot (green) when unread
                                      if (hasUnread)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 14),

                                  /// NAME + LAST MESSAGE
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.name ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: hasUnread
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (user.roleName != null &&
                                                user.roleName!.isNotEmpty) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .app_background_clr
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  user.roleName!,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors
                                                        .app_background_clr,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (user.lastMessage?.message != null &&
                                            user
                                                .lastMessage!
                                                .message!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            user.lastMessage!.message!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: hasUnread
                                                      ? theme
                                                            .colorScheme
                                                            .onSurface
                                                      : theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.6),
                                                  fontWeight: hasUnread
                                                      ? FontWeight.w500
                                                      : FontWeight.normal,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  /// UNREAD COUNT BADGE
                                  if (hasUnread)
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 22,
                                        minHeight: 22,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.app_background_clr,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unread > 99 ? '99+' : '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const NoInternetScreen(),
      ),
    );
  }
}
