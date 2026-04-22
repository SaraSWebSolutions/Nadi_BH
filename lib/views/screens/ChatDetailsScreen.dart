import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/active_chat_provider.dart';
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
      _isAdmin ? AppColors.app_background_clr  : AppColors.btn_primery;

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
      debugPrint("✅ Stream Chat connected. Current user: ${client.state.currentUser?.id}");
      debugPrint("✅ WebSocket status: ${client.wsConnectionStatus}");

      // ✅ Extra safety: verify WebSocket is actually connected
      if (client.wsConnectionStatus != ConnectionStatus.connected) {
        debugPrint("⚠️ WebSocket not connected after connectUserIfNeeded — waiting...");
        // Give it a moment to establish
        await Future.delayed(const Duration(seconds: 2));
        if (client.wsConnectionStatus != ConnectionStatus.connected) {
          throw Exception('WebSocket connection failed. Please check your internet and try again.');
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
      debugPrint("✅ Channel watched successfully. Messages: ${ch.state?.messages.length ?? 0}");

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
      backgroundColor: _isAdmin ? AppColors.app_background_clr  : Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _isAdmin ? Colors.white : Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _isAdmin
                ? Colors.white.withValues(alpha: 0.25)
                : _otherPartyColor,
            child: Text(
              (widget.adminName?.isNotEmpty ?? false)
                  ? widget.adminName![0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: _isAdmin ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.adminName ?? loc.chat,
                  style: TextStyle(
                    color: _isAdmin ? Colors.white : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.roleName != null && widget.roleName!.isNotEmpty)
                  Text(
                    widget.roleName!,
                    style: TextStyle(
                      color: _isAdmin
                          ? Colors.white70
                          : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _isAdmin ? AppColors.app_background_clr  : Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: _isAdmin ? Colors.white : Colors.black),
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
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  loc.couldNotLoadChat,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                  reverse: true,
                  shrinkWrap: true,
                  messageBuilder: (context, details, messages, defaultMessage) {
                    final message = details.message;
                    final currentUser =
                        StreamChat.of(context).client.state.currentUser;
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
                        vertical: 4, horizontal: 10),
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
                messageInputTheme: StreamMessageInputThemeData(
                  inputBackgroundColor: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  inputDecoration:  InputDecoration(
                    hintText: loc.writeMessage,
                      hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
        
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    
                  ),
                     // ✅ FIX: icon colors (left & right)
      actionButtonColor: Theme.of(context).iconTheme.color,
      sendButtonColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: StreamMessageInput(
                attachmentButtonBuilder: (context, onPressed) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
