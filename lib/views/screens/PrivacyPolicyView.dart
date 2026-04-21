import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/providers/Privacypolicy_Provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyView extends ConsumerWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(Privacypolicyprovider);
  final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title:  Text(
         l10n.privacyPolicy,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.app_background_clr,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: privacyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (privacy) {
          final item = privacy.data.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: "${ImageBaseUrl.baseUrl}/${item.media}",
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.app_background_clr.withOpacity(0.08),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.privacy_tip_outlined, size: 50, color: AppColors.app_background_clr.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            l10n.privacyPolicy,
                            style: TextStyle(
                              color: AppColors.app_background_clr.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...item.content.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      text,
                      textAlign: TextAlign.justify, // Better for long legal text
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(item.link),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(
                    item.link,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
