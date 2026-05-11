import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/utils/BlinkingDot.dart';
import 'package:nadi_user_app/core/utils/CommonNetworkImage.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'package:nadi_user_app/core/utils/snackbar_helper.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/models/Questioner_Model.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/Advertisement_Provider.dart';
import 'package:nadi_user_app/providers/Questioner_Provider.dart';
import 'package:nadi_user_app/providers/connectivity_provider.dart';
import 'package:nadi_user_app/providers/fetchpointsnodification.dart';
import 'package:nadi_user_app/providers/gift_provider.dart';
import 'package:nadi_user_app/providers/notification_unread_provider.dart';
import 'package:nadi_user_app/providers/serviceProvider.dart';
import 'package:nadi_user_app/providers/userDashboard_provider.dart';
import 'package:nadi_user_app/services/home_view_service.dart';
import 'package:nadi_user_app/services/ongoing_service.dart';
import 'package:nadi_user_app/views/screens/Advertisement_View.dart';
import 'package:nadi_user_app/views/screens/Questioner_View.dart';
import 'package:nadi_user_app/widgets/gift_animation_overlay.dart';
import 'package:nadi_user_app/widgets/animated_envelope.dart';
import 'package:nadi_user_app/widgets/no_internet_widget.dart';

import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/views/screens/AddPointBottomSheet.dart';
import 'package:nadi_user_app/widgets/RecentActivity.dart';
import 'package:nadi_user_app/widgets/app_card.dart';
import 'package:nadi_user_app/widgets/pie_chart.dart';
import 'package:nadi_user_app/widgets/request_cart.dart';
import 'package:app_badge_plus/app_badge_plus.dart';

class Dashboard extends ConsumerStatefulWidget {
  final Function(int) onTabChange;
  const Dashboard({super.key, required this.onTabChange});
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  String userName = "";
  String accountType = "";
  String _rawAccountType = "";
  final HomeViewService _homeViewService = HomeViewService();
  final OngoingService _ongoingService = OngoingService();
  DateTime? lastBackPressed;
  Map<String, dynamic>? _ongoing;
  Map<String, dynamic>? _aprovetech;
  Timer? _notificationTimer;
  final GlobalKey<RecentActivityState> recentActivityKey =
      GlobalKey<RecentActivityState>();
  Future<void> updateAppBadge(int count) async {
    try {
      if (count > 0) {
        await AppBadgePlus.updateBadge(count);
      } else {
        await AppBadgePlus.updateBadge(0); // clears badge
      }
    } catch (e) {
      debugPrint("❌ Badge not supported: $e");
    }
  }
  // @override
  // void initState() {
  //   super.initState();

  //   get_preferencevalue();
  //   fetchongoinproces();
  //   fetchapprovetechnician();
  //   Future.microtask(() {
  //     ref.read(serviceListProvider.notifier).refresh();
  //     ref.refresh(fetchpointsnodification);
  //     ref.refresh(fetchadvertisementprovider);
  //     ref.refresh(userdashboardprovider);
  //     ref.refresh(fetchquestionsdataprovider);
  //   });
  // }

  DateTime? _lastSeenTime;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Notification badge listener
      ref.listen(unreadNotificationCountProvider, (previous, next) {
        next.whenData((count) {
          updateAppBadge(count);
        });
      });

      /// Question popup listener
      ref.listen<AsyncValue<Questioner>>(fetchquestionsdataprovider, (
        previous,
        next,
      ) async {
        if (next is AsyncData<Questioner>) {
          final data = next.value;

          if (data.data.isEmpty) return;

          if (ModalRoute.of(context)?.isCurrent != true) return;

          await Future.delayed(const Duration(milliseconds: 300));

          if (!context.mounted) return;

          showQuestionPopup(context, data.data.first);
        }
      });
    });
  }

  Future<void> _checkGift() async {
    try {
      final gift = await ref.read(giftStatusProvider.future);
      if (gift.showAnimation && mounted) {
        ref.read(showGiftOverlayProvider.notifier).updateState(true);
      }
    } catch (_) {}
  }

  Future<void> fetchongoinproces() async {
    try {
      final result = await _ongoingService.fetchongoingprocess();
      setState(() {
        _ongoing = result;
      });
      AppLogger.warn("RESULT: $_ongoing");
    } catch (e) {
      AppLogger.error("ERROR: $e");
    }
  }

  Future<void> _refreshDashboardData() async {
    ref.read(serviceListProvider.notifier).refresh();

    ref.invalidate(fetchpointsnodification);
    ref.invalidate(fetchadvertisementprovider);
    ref.invalidate(userdashboardprovider);
    ref.invalidate(fetchquestionsdataprovider);

    await Future.wait([fetchongoinproces(), fetchapprovetechnician()]);

    // ✅ Refresh RecentActivity
    await recentActivityKey.currentState?.LogsData();

    AppLogger.success("✅ Dashboard refreshed");

    AppLogger.success("✅ Dashboard refreshed");
  }

  Future<void> fetchapprovetechnician() async {
    try {
      final aprovedata = await _ongoingService.fetchaprovetech();

      // 🔹 Log raw response
      AppLogger.warn("fetchapprovetechnician raw response: $aprovedata");

      // ✅ Check mounted before setState
      if (!mounted) return;

      setState(() {
        // ✅ allow null safely
        _aprovetech = aprovedata;
      });
    } catch (e, stack) {
      AppLogger.error("fetchapprovetechnician error: $e");

      AppLogger.error(stack.toString());

      // ✅ Prevent refresh crash
      if (!mounted) return;

      setState(() {
        _aprovetech = null;
      });
    }
  }

  Future<void> approvework(bool isApproved) async {
    if (_aprovetech == null || _aprovetech!['data'] == null) return;

    final aprovetech = _aprovetech!['data'];

    final payload = {
      "userServiceId": aprovetech['userServiceId'],
      "techniciainId": aprovetech['techniciainId'],
      "status": isApproved,
    };

    debugPrint("📤 ApproveWork Payload: $payload");

    try {
      final result = await _ongoingService.fetchabrovework(payload: payload);

      if (!context.mounted) return;

      /// ✅ REMOVE POPUP IMMEDIATELY
      setState(() {
        _aprovetech = null;
      });

      /// ✅ SHOW CORRECT MESSAGE
      if (isApproved) {
        SnackbarHelper.ShowSuccess(context, "Work approved successfully");
      } else {
        SnackbarHelper.ShowSuccess(context, "Work rejected successfully");
      }

      /// ⚠️ IMPORTANT: Delay refresh to avoid flicker / re-show
      // Future.delayed(const Duration(seconds: 1), () {
      //   fetchapprovetechnician();
      // });

      AppLogger.info("Approve result: $result");
    } catch (e) {
      AppLogger.error("Approve error: $e");
    }
  }

  Future<void> get_preferencevalue() async {
    final type = await AppPreferences.getaccounttype();
    final name = await AppPreferences.getusername();
    if (!mounted) return;
    setState(() {
      _rawAccountType = type ?? "";
      accountType = type == "IA" ? "Individual" : "Family";
      userName = name ?? "";
    });
  }

  Widget serviceShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 60, height: 8, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget statusItem(Color color, String text) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: text == "Completed"
                ? AppColors.btn_primery
                : text == "Pending"
                ? Colors.grey
                : AppColors.gold_coin,
          ),
        ),
      ],
    );
  }

  Future<void> showQuestionPopup(
    BuildContext context,
    QuestionerDatum question,
  ) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false, //  DO NOT CLOSE ON OUTSIDE CLICK
      barrierLabel: "Question Popup",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        question.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(child: QuestionerView(questionerDatum: question)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceListProvider);
    final dashboardAsync = ref.watch(userdashboardprovider);
    // final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final adAsync = ref.watch(fetchadvertisementprovider);
    final connectivity = ref.watch(connectivityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final data = _ongoing?['data'];
    final t = AppLocalizations.of(context)!;
    final bool isOngoing = data != null && data['status'] == 'inProgress';
    final aprovetech = _aprovetech?['data'];
    ref.listen(unreadNotificationCountProvider, (previous, next) {
      next.whenData((count) {
        updateAppBadge(count);
      });
    });
    ref.listen<AsyncValue<Questioner>>(fetchquestionsdataprovider, (
      previous,
      next,
    ) async {
      if (next is AsyncData<Questioner>) {
        final data = next.value;
        if (data.data.isEmpty) return;
        // Prevent duplicate dialog
        if (ModalRoute.of(context)?.isCurrent != true) return;
        await Future.delayed(const Duration(milliseconds: 300));
        if (!context.mounted) return;

        showQuestionPopup(context, data.data.first);
      }
    });

    // Old gift overlay removed in favor of stack-based component

    final l10n = AppLocalizations.of(context)!;

    final showGift = ref.watch(showGiftOverlayProvider);
    final giftAsync = ref.watch(giftStatusProvider);

    return Scaffold(
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              final isOnline = connectivity.value ?? true;
              if (!isOnline) {
                return NoInternetScreen();
              }
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   // image: AssetImage("assets/images/background_img.png"),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: RefreshIndicator(
                  onRefresh: _refreshDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          height: 170,
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            // color: AppColors.btn_primery,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.app_background_clr,
                                const Color.fromARGB(255, 173, 183, 225),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(51),
                              bottomRight: Radius.circular(51),
                            ),
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 35),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    dashboardAsync.when(
                                      loading: () => Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                            ),

                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 70,
                                                  height: 12,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  width: 120,
                                                  height: 16,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      error: (e, _) => const Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),

                                      data: (dashboard) {
                                        return Row(
                                          children: [
                                            dashboard.image.isEmpty
                                                ? Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: AppColors
                                                            .btn_primery,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: const CircleAvatar(
                                                      radius: 22,
                                                      backgroundColor:
                                                          Colors.blue,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        "${ImageBaseUrl.baseUrl}/${dashboard.image}",
                                                    imageBuilder:
                                                        (
                                                          context,
                                                          imageProvider,
                                                        ) => CircleAvatar(
                                                          radius: 22,
                                                          backgroundImage:
                                                              imageProvider,
                                                        ),
                                                    placeholder: (_, __) =>
                                                        const CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                    errorWidget: (_, __, ___) =>
                                                        const Icon(
                                                          Icons.person,
                                                        ),
                                                  ),

                                            const SizedBox(width: 12),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.welcome,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  dashboard.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    // Notification envelope widget updated to use time-based logic.
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final unreadCountAsync = ref.watch(
                                          unreadNotificationCountProvider,
                                        );

                                        return unreadCountAsync.when(
                                          data: (newNotifications) {
                                            return AnimatedEnvelope(
                                              unreadCount: newNotifications,
                                              onTap: () async {
                                                DateTime seenTime =
                                                    DateTime.now().toUtc();

                                                final currentNotifications = ref
                                                    .read(
                                                      fetchpointsnodification,
                                                    )
                                                    .value
                                                    ?.data;

                                                if (currentNotifications !=
                                                        null &&
                                                    currentNotifications
                                                        .isNotEmpty) {
                                                  seenTime =
                                                      currentNotifications
                                                          .map((n) => n.time)
                                                          .reduce(
                                                            (a, b) =>
                                                                a.isAfter(b)
                                                                ? a
                                                                : b,
                                                          );
                                                }

                                                await AppPreferences.saveLastSeenNotificationTime(
                                                  seenTime,
                                                );

                                                ref.invalidate(
                                                  unreadNotificationCountProvider,
                                                );

                                                if (context.mounted) {
                                                  context
                                                      .push(
                                                        RouteNames
                                                            .pointnodification,
                                                      )
                                                      .then((_) {
                                                        ref.invalidate(
                                                          unreadNotificationCountProvider,
                                                        );
                                                      });
                                                }

                                                await updateAppBadge(0);
                                              },
                                            );
                                          },
                                          loading: () => AnimatedEnvelope(
                                            unreadCount: 0,
                                            onTap: () {},
                                          ),
                                          error: (_, __) => AnimatedEnvelope(
                                            unreadCount: 0,
                                            onTap: () {},
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              dashboardAsync.when(
                                loading: () => const SizedBox(),
                                error: (_, __) => const SizedBox(),
                                data: (dashboard) {
                                  return Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            dashboard.account,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black, // 👈 ADD THIS
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            context.push(
                                              RouteNames.pointdetails,
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            height: 38,
                                            constraints: const BoxConstraints(
                                              minWidth: 90,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: AppColors.gold_coin,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  "assets/icons/gold_coin.png",
                                                  height: 22,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "${dashboard.points}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        aprovetech != null
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// 🔹 TOP ROW (ICON + TEXT)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// ICON
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.engineering,
                                            color: Colors.green,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        /// TEXT
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.approvalNeeded,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      16, // 🔥 slightly bigger
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.technicianApprovalMessage,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    /// 🔹 BUTTON ROW
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        /// ❌ REJECT
                                        InkWell(
                                          onTap: () {
                                            approvework(false);
                                          },
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  t.reject,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        /// ✅ APPROVE
                                        InkWell(
                                          onTap: () {
                                            approvework(true);
                                          },
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  t.approve,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),

                        data != null
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // LEFT: Icon
                                    Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // CENTER: Technician name + Request ID
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['technicianName'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Request ID: ${data['requestId']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // RIGHT: Status chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOngoing
                                            ? Colors.green.shade50
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isOngoing) ...[
                                            const BlinkingDot(),
                                            const SizedBox(width: 6),
                                          ],
                                          Text(
                                            isOngoing ? "ONGOING" : "COMPLETED",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isOngoing
                                                  ? Colors.green.shade800
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        adAsync.when(
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                          data: (model) {
                            if (model.data.isEmpty) return const SizedBox();
                            return const AdvertisementCarousel();
                          },
                        ),

                        SizedBox(height: 10),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 22,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.quickAction,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      fontSize: AppFontSizes.medium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 22,
                                  width: 66,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        const BorderRadiusDirectional.only(
                                          topStart: Radius.circular(10),
                                          bottomStart: Radius.circular(10),
                                        ),
                                    color: AppColors.app_background_clr,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      context.push(RouteNames.allservice);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      l10n.more,

                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSizes.small,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              height: 110,
                              child: services.isEmpty
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      itemCount: 5,
                                      itemBuilder: (_, __) =>
                                          serviceShimmerItem(),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      itemCount: services.length,
                                      itemBuilder: (context, index) {
                                        final service = services[index];
                                        final String name =
                                            service['name'] ?? '';
                                        final String serviceId =
                                            service['_id'] ?? "";
                                        final String? logo =
                                            service['serviceLogo'];
                                        final int points =
                                            int.tryParse(
                                              service['points'].toString(),
                                            ) ??
                                            0;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  context.push(
                                                    RouteNames
                                                        .sendservicerequest,
                                                    extra: {
                                                      'title': name,
                                                      "imagePath":
                                                          "${ImageBaseUrl.baseUrl}/${service['serviceImage']}",
                                                      'serviceId': serviceId,
                                                      "points": points,
                                                    },
                                                  );
                                                },
                                                child: AppCard(
                                                  width: 70,
                                                  height: 70,
                                                  child: CommonNetworkImage(
                                                    imageUrl:
                                                        "${ImageBaseUrl.baseUrl}/$logo",
                                                    size: 30,
                                                  ),
                                                  // logo != null
                                                  //     ? SvgPicture.network(
                                                  //         "${ImageBaseUrl.baseUrl}/$logo",
                                                  //         fit: BoxFit.contain,
                                                  //         placeholderBuilder: (context) =>
                                                  //             const Icon(
                                                  //               Icons.image,
                                                  //               size: 30,
                                                  //             ),
                                                  //       )
                                                  //     : const Icon(
                                                  //         Icons.miscellaneous_services,
                                                  //       ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  name,
                                                  maxLines: 1, //  limit lines
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RequestCart(
                                      title: "",
                                      image: const SizedBox.shrink(),
                                      centerIcon: Builder(
                                        builder: (_) {
                                          final unread = ref
                                              .watch(
                                                unreadNotificationCountProvider,
                                              )
                                              .maybeWhen(
                                                data: (count) => count,
                                                orElse: () => 0,
                                              );

                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              const Icon(
                                                Icons.mail_rounded,
                                                color: Colors.white,
                                                size: 70,
                                              ),

                                              /// ✅ BADGE ON ENVELOPE ICON (CORRECT POSITION)
                                              if (unread > 0)
                                                Positioned(
                                                  top: -4,
                                                  right: -4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 18,
                                                          minHeight: 18,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF4444),
                                                              Color(0xFFCC0000),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      unread > 99
                                                          ? '99+'
                                                          : '$unread',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                      color: AppColors.app_background_clr,
                                      onTap: () async {
                                        DateTime seenTime = DateTime.now()
                                            .toUtc();

                                        final currentNotifications = ref
                                            .read(fetchpointsnodification)
                                            .value
                                            ?.data;

                                        if (currentNotifications != null &&
                                            currentNotifications.isNotEmpty) {
                                          seenTime = currentNotifications
                                              .map((n) => n.time)
                                              .reduce(
                                                (a, b) => a.isAfter(b) ? a : b,
                                              );
                                        }

                                        await AppPreferences.saveLastSeenNotificationTime(
                                          seenTime,
                                        );

                                        ref.invalidate(
                                          unreadNotificationCountProvider,
                                        );

                                        if (context.mounted) {
                                          context
                                              .push(
                                                RouteNames.pointnodification,
                                              )
                                              .then((_) {
                                                ref.invalidate(
                                                  unreadNotificationCountProvider,
                                                );
                                              });
                                        }

                                        await updateAppBadge(0);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: RequestCart(
                                      title: AppLocalizations.of(
                                        context,
                                      )!.addPoint,
                                      image: Image.asset(
                                        "assets/icons/gold_coin.png",
                                      ),
                                      color: AppColors.gold_coin,
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) =>
                                              AddPointBottomSheetContent(
                                                accountType: _rawAccountType,
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 20,
                              ),
                              child: Container(
                                height: 172,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.serviceOverview,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 27,
                                            width: 90,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                widget.onTabChange(
                                                  1,
                                                ); // Switch to service tab
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                backgroundColor: AppColors
                                                    .app_background_clr,
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  l10n.details,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: DonutChartExample(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Theme.of(context).colorScheme.surface,
                                ),

                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.recentActivity,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.medium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => context.push(
                                              RouteNames.viewalllogs,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.viewAll,
                                              style: TextStyle(
                                                fontSize: AppFontSizes.small,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.borderGrey,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: AppColors.borderGrey,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            RecentActivity(
                              key: recentActivityKey,
                              limitLogs: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // === GIFT OVERLAY ===
          if (showGift && giftAsync.hasValue && giftAsync.value!.showAnimation)
            GiftAnimationOverlay(
              title: giftAsync.value!.title,
              points: giftAsync.value!.points,
              message: giftAsync.value!.message,
              onDismiss: () async {
                ref.read(showGiftOverlayProvider.notifier).updateState(false);
                try {
                  await ref.read(giftServiceProvider).dismiss();
                  ref.refresh(userdashboardprovider);
                } catch (_) {}
              },
            ),
        ],
      ),
    );
  }
}
