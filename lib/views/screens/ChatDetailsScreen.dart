import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/active_chat_provider.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:nadi_user_app/services/Stream_Chat_Service.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  final String? adminId;
  final String? adminName;
  final String? roleName;

  const ChatDetailsScreen({
    super.key,
    this.adminId,
    this.adminName,
    this.roleName,
  });

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen>
    with WidgetsBindingObserver {
  late final StreamChatClient client;
  Channel? channel;
  String? _errorMessage;
  bool _isLoading = true;
  StreamSubscription? _messageSubscription;

  bool get _isAdmin {
    final role = widget.roleName?.toLowerCase() ?? '';
    return role == 'admin' || role == 'super admin' || role == 'superadmin';
  }

  // Distinct color for admin vs regular user in the AppBar / avatars
  Color get _otherPartyColor =>
      _isAdmin ? AppColors.app_background_clr : AppColors.btn_primery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    client = StreamChatService().client;
    _initializeChat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && channel != null) {
      // ✅ On resume, check if WebSocket is still alive and reconnect if needed
      _ensureConnectionAndMarkRead();
    }
  }

  /// ✅ Ensure Stream Chat is connected before marking as read
  Future<void> _ensureConnectionAndMarkRead() async {
    try {
      final userId = await AppPreferences.getUserId();
      if (userId != null) {
        await StreamChatService().connectUserIfNeeded(userId);
      }
      try {
        await channel?.markRead();
      } catch (_) {
        // Silently ignore markRead failures
      }
    } catch (e) {
      debugPrint("⚠️ Reconnect on resume failed: $e");
    }
  }

  Future<void> _initializeChat() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = await AppPreferences.getUserId();
      final adminId = widget.adminId;
      debugPrint("🔵 Chat init: userId=$userId, adminId=$adminId");

      if (userId == null || adminId == null) {
        throw Exception('Missing user information. Please log in again.');
      }

      debugPrint("🔵 Connecting Stream Chat for user: $userId");
      await StreamChatService().connectUserIfNeeded(userId);
      debugPrint(
        "✅ Stream Chat connected. Current user: ${client.state.currentUser?.id}",
      );
      debugPrint("✅ WebSocket status: ${client.wsConnectionStatus}");

      // ✅ Extra safety: verify WebSocket is actually connected
      if (client.wsConnectionStatus != ConnectionStatus.connected) {
        debugPrint(
          "⚠️ WebSocket not connected after connectUserIfNeeded — waiting...",
        );
        // Give it a moment to establish
        await Future.delayed(const Duration(seconds: 2));
        if (client.wsConnectionStatus != ConnectionStatus.connected) {
          throw Exception(
            'WebSocket connection failed. Please check your internet and try again.',
          );
        }
      }

      final sortedIds = [userId, adminId]..sort();
      final channelId = sortedIds.join('_');
      debugPrint("🔵 Creating channel: $channelId with members: $sortedIds");

      final ch = client.channel(
        'messaging',
        //id: channelId,
        extraData: {
          'members': [userId, adminId],
        },
      );

      debugPrint("🔵 Watching channel...");
      await ch.watch();
      debugPrint(
        "✅ Channel watched successfully. Messages: ${ch.state?.messages.length ?? 0}",
      );

      // Mark messages as read immediately — silently ignored if it fails
      try {
        await ch.markRead();
      } catch (_) {}

      // Listen for new messages and mark them as read immediately
      _messageSubscription = ch.on(EventType.messageNew).listen((_) {
        ch.markRead().ignore();
      });

      if (mounted) {
        setState(() {
          channel = ch;
          _isLoading = false;
        });
        ref.read(activeChatChannelProvider.notifier).updateState(ch.id);
      }
    } catch (e, stack) {
      debugPrint("❌ Chat init failed: $e");
      debugPrint("❌ Stack: $stack");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    ref.read(activeChatChannelProvider.notifier).updateState(null);
    super.dispose();
  }

  AppBar _buildAppBar() {
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.app_background_clr,
      elevation: 0,
      centerTitle: true,

      title: Text(
        widget.adminName ?? loc.chat,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        overflow: TextOverflow.ellipsis,
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
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _isAdmin
              ? AppColors.app_background_clr
              : Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: _isAdmin ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.adminName ?? loc.chat,
            style: TextStyle(
              color: _isAdmin ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.adminName ?? loc.chat,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.couldNotLoadChat,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.checkConnectionTryAgain,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _initializeChat,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamChannel(
      channel: channel!,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: StreamMessageListView(
                  showFloatingDateDivider: false,
                  reverse: true,
                  shrinkWrap: true,
                  messageBuilder: (context, details, messages, defaultMessage) {
                    final message = details.message;
                    final currentUser = StreamChat.of(
                      context,
                    ).client.state.currentUser;
                    final isMe = message.user?.id == currentUser?.id;

                    if (isMe) {
                      return defaultMessage.copyWith(
                        showUsername: false,
                        showUserAvatar: DisplayWidget.gone,
                      );
                    }

                    // Other party (admin or user) — show avatar with role-based color
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _otherPartyColor,
                            child: Text(
                              (widget.adminName?.isNotEmpty ?? false)
                                  ? widget.adminName![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: defaultMessage.copyWith(
                              showUsername: false,
                              showUserAvatar: DisplayWidget.gone,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            StreamChatTheme(
              data: StreamChatThemeData.fromTheme(Theme.of(context)).copyWith(
                ownMessageTheme: StreamMessageThemeData(
                  messageBackgroundColor: AppColors.app_background_clr,

                  // ✅ Better visible border
                  messageBorderColor: Colors.white.withOpacity(0.15),

                  messageTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),

                  avatarTheme: const StreamAvatarThemeData(
                    constraints: BoxConstraints.tightFor(width: 0, height: 0),
                  ),
                ),

                otherMessageTheme: StreamMessageThemeData(
                  // ✅ Better dark mode bubble
                  messageBackgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F1F1F)
                      : Colors.grey.shade200,

                  // ✅ Visible border
                  messageBorderColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.06),

                  // ✅ Better readable text
                  messageTextStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),

                  avatarTheme: const StreamAvatarThemeData(
                    constraints: BoxConstraints.tightFor(width: 0, height: 0),
                  ),
                ),

                messageInputTheme: StreamMessageInputThemeData(
                  inputBackgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),

                  inputDecoration: InputDecoration(
                    hintText: loc.writeMessage,

                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.app_background_clr,
                      ),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.app_background_clr,
                        // width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.button_secondary,
                        //width: 2,
                      ),
                    ),
                  ),

                  actionButtonColor: Theme.of(context).iconTheme.color,

                  sendButtonColor: AppColors.app_background_clr,
                ),
              ),

              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0D0D0D)
                    : Colors.white,

                child: StreamMessageInput(
                  attachmentButtonBuilder: (context, onPressed) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
