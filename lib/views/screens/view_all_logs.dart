import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/widgets/RecentActivity.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

class ViewAllLogs extends StatefulWidget {
  const ViewAllLogs({super.key});

  @override
  State<ViewAllLogs> createState() => _ViewAllLogsState();
}

class _ViewAllLogsState extends State<ViewAllLogs> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.myRecentActivity,
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

      body: Column(
        children: [
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          const Expanded(child: RecentActivity(limitLogs: false)),
        ],
      ),
    );
  }
}
