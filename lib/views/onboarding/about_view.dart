import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/routing/app_router.dart';
import 'package:nadi_user_app/providers/onbording_provider.dart';

// Background image per slide
const _slideImages = [
  'assets/images/onboarding/1774802367130_PAGE-No5A.png',
  'assets/images/onboarding/1774802367130_PAGE-No5B.png',
  'assets/images/onboarding/1774802367131_PAGE-No5C.png',
];

class AboutView extends ConsumerStatefulWidget {
  const AboutView({super.key});
  @override
  ConsumerState<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends ConsumerState<AboutView> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  static const double _imageHeightFraction = 0.56;

  Future<void> goToLogin() async {
    await AppPreferences.setAboutSeen(true);
    if (mounted) context.go(RouteNames.login);
  }

  void nextPage(int total) {
    if (currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final aboutAsync = ref.watch(aboutContentProvider);
    final topPadding = MediaQuery.of(context).padding.top;
final isRTL = Directionality.of(context) == TextDirection.rtl;
final locale = Localizations.localeOf(context);
final isArabic = locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ── BACKGROUND IMAGE (changes per slide) ──────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
    IgnorePointer(
                child:  AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(
                    _slideImages[currentIndex.clamp(0, _slideImages.length - 1)],
                    key: ValueKey(currentIndex),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),),
                /// ── HEADER (Back, Title, Skip) ────────────────────────────────
               Positioned(
  top: topPadding + 12,
  left: 15,
  right: 15,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      
      /// BACK BUTTON (flip in RTL)
    Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(50),
   onTap: () {
  // print("BACK PRESSED");

  if (context.canPop()) {
    context.pop();
  } else {
  context.go(RouteNames.welcome);
  }
},
    child: Container(
      height: 36,
      width: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !isArabic
            ? AppColors.app_background_clr
            : Colors.white.withOpacity(0.25),
      ),
      child: Icon(
        isRTL ? Icons.arrow_forward : Icons.arrow_back,
        color: Colors.white,
        size: 20,
      ),
    ),
  ),
),
      /// TITLE
      Text(
        AppLocalizations.of(context)!.about,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: "Poppins",
        ),
      ),

      /// SKIP BUTTON (always visible in BOTH languages)
      GestureDetector(
        onTap: goToLogin,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color:isArabic? AppColors.app_background_clr:Colors.white.withOpacity(0.25),
          ),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.skip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.double_arrow,
                  size: 13, color: Colors.white),
            ],
          ),
        ),
      ),
    ],
  ),
),
              ],
            ),
          ),

          /// ── CONTENT AREA (below the image curve) ──────────────────────
          Expanded(
            flex: 4,
            child: aboutAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text("${AppLocalizations.of(context)!.errorLabel}: $err"),
              ),
              data: (textPages) {
                if (textPages.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noContent),
                  );
                }
                return Column(
                  children: [
                    /// Text pages
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: textPages.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 10),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                              child: Text(
                                textPages[index],
                                key: ValueKey(textPages[index]),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.small,
                                  height: 1.6,
                                  fontFamily: "Poppins",
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// Dots + Next button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),

                          // Dot indicators
                          Row(
                            children: List.generate(
                              textPages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: i == currentIndex ? 22 : 8,
                                decoration: BoxDecoration(
                                  color: i == currentIndex
                                      ? AppColors.app_background_clr
                                      : AppColors.app_background_clr
                                          .withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          // Next button
                          GestureDetector(
                            onTap: () => nextPage(textPages.length),
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.app_background_clr,
                              ),
                              child: Icon(
                                currentIndex == textPages.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

