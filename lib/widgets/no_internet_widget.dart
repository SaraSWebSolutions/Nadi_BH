import 'package:flutter/material.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Icon(
                Icons.wifi_off,
                size: 80,
                color: Colors.grey,
              ),

              SizedBox(height: 20),

              /// TITLE
              Text(
                l10n.noInternetConnectionTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              /// DESCRIPTION
              Text(
                l10n.noInternetConnectionMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
