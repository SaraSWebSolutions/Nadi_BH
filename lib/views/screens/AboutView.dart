import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/aboutProvider.dart';
import 'package:nadi_user_app/widgets/app_back.dart';

class AboutsView extends ConsumerWidget {
  const AboutsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutAsync = ref.watch(aboutProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,

        title: Text(
          AppLocalizations.of(context)!.aboutApp,
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
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: aboutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (about) {
          if (about.data.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noContentAvailable),
            );
          }
          final item = about.data.first;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: item.content.isEmpty
                          ? [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.noContentAvailable,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                          : item.content
                                .map(
                                  (text) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      text,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                                .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.versionLabel(item.version),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
