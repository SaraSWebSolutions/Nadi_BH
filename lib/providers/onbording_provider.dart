import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/providers/language_provider.dart';
import 'package:nadi_user_app/services/onbording_service.dart';

final onbordingServiceProvider = Provider((ref) {
  return OnbordingService();
});

/// Real onboarding content — replaces Lorem Ipsum from the API.
const _contentEn = <String>[
  // Page 1
  "Your trusted partner for home and business services in Bahrain. "
      "From maintenance and repairs to specialized technical support — "
      "request any service and get connected with certified professionals instantly.",
  // Page 2
  "Create a service request in seconds. Our verified technicians receive "
      "your request instantly and respond in real-time. Track your request status, "
      "chat directly with your assigned technician, and earn reward points with "
      "every completed service.",
  // Page 3
  "Join thousands of satisfied customers across Bahrain. Sign up with your "
      "phone number, add your family members to your account, and enjoy fast, "
      "reliable service — all from one app.",
];

const _contentAr = <String>[
  // Page 1
  "شريكك الموثوق لخدمات المنازل والأعمال في البحرين. "
      "من الصيانة والإصلاحات إلى الدعم الفني المتخصص — "
      "اطلب أي خدمة وتواصل مع محترفين معتمدين فوراً.",
  // Page 2
  "أنشئ طلب خدمة في ثوانٍ. يتلقى الفنيون المعتمدون لدينا طلبك فوراً "
      "ويستجيبون في الوقت الفعلي. تتبع حالة طلبك، تحدث مباشرة مع الفني "
      "المعين لك، واكسب نقاط مكافآت مع كل خدمة مكتملة.",
  // Page 3
  "انضم إلى آلاف العملاء الراضين في جميع أنحاء البحرين. "
      "سجّل برقم هاتفك، أضف أفراد عائلتك إلى حسابك، "
      "واستمتع بخدمة سريعة وموثوقة — كل ذلك من تطبيق واحد.",
];

final aboutContentProvider = FutureProvider<List<String>>((ref) async {
  final locale = ref.watch(languageProvider);
  final lang = locale.languageCode;

  // Return real content based on language
  return lang == 'ar' ? _contentAr : _contentEn;
});

