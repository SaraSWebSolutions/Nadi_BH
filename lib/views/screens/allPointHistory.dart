import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/utils/Time_Date.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/pointshistory_provider.dart';
import 'package:nadi_user_app/widgets/app_back.dart';
import 'package:nadi_user_app/widgets/individual_points_card.dart';

class AllPointHistory extends ConsumerStatefulWidget {
  const AllPointHistory({super.key});

  @override
  ConsumerState<AllPointHistory> createState() => _AllPointHistoryState();
}

class _AllPointHistoryState extends ConsumerState<AllPointHistory> {
  @override
  void initState() {
    super.initState();
    ref.refresh(pointshistoryprovider);
  }

  @override
  Widget build(BuildContext context) {
    final pointhistoryAsync = ref.watch(pointshistoryprovider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.gold_coin,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.pointHistorys,
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
                  color: const Color(0xFFF6C956),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),

      body: pointhistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (response) {
          final data = response.data;

          if (data.isEmpty) {
            return Center(child: Text(l10n.noHistoryFound));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IndividualPointsCard(
                  date: formatIsoDateForUI(item.updatedAt.toString()),
                  text: item.history,
                  status: item.status,
                  points: item.points.toString(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
