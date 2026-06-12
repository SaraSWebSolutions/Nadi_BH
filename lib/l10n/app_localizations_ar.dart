// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get about => 'حول';

  @override
  String get skip => 'تخطي';

  @override
  String get nadiBahrainServices => 'خدمات نادي البحرين';

  @override
  String get welcome => 'مرحبا!';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signInWithOtp => 'تسجيل الدخول باستخدام OTP';

  @override
  String get signUp => 'تسجيل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get or => 'أو';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get sendEmail => 'إرسال البريد الإلكتروني';

  @override
  String get emailSentMessage => 'تم إرسال البريد الإلكتروني بنجاح';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get otpSentMessage => 'لقد أرسلنا لك رمز تحقق مكون من 4 أرقام على';

  @override
  String get resendOtp => 'إعادة إرسال OTP';

  @override
  String resendOtpIn(Object seconds) {
    return 'إعادة إرسال OTP خلال 00:$seconds';
  }

  @override
  String get otpSignIn => 'تسجيل الدخول';

  @override
  String get enter4DigitOtp => 'الرجاء إدخال رمز OTP المكون من 4 أرقام';

  @override
  String get accountTypeTitle => 'نوع الحساب';

  @override
  String get individualAccount => 'حساب فردي';

  @override
  String get individualAccountDesc => 'إدارة خدماتك وملفك الشخصي بشكل مستقل.';

  @override
  String get familyAccount => 'حساب عائلي';

  @override
  String get familyAccountDesc =>
      'تسجيل وإدارة الخدمات لأعضاء العائلة المتعددين.';

  @override
  String get signUpTitle => 'سجل';

  @override
  String get accountVerificationTitle =>
      'قم بتأمين حسابك من خلال التحقق من الهوية';

  @override
  String get accountVerificationDesc1 =>
      'لضمان أعلى مستوى من الأمان والثقة داخل مجتمع Service Connect، نطلب من جميع المستخدمين إكمال عملية تحقق بسيطة من الهوية. هذا يساعد على الحماية من الاحتيال والحفاظ على بيئة آمنة للجميع.';

  @override
  String get accountVerificationDesc2 =>
      'نحن نقدر سلامتك وخصوصيتك. تتم معالجة معلوماتك بأمان وتستخدم فقط لأغراض التحقق.';

  @override
  String get continueButton => 'استمر';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم الهاتف';

  @override
  String get phoneMustBe8Digits => 'يجب أن يتكون رقم الهاتف من 8 أرقام';

  @override
  String get sendOtp => 'إرسال رمز OTP';

  @override
  String get enterOtp => 'أدخل رمز OTP';

  @override
  String get enterValidOtp => 'أدخل رمز OTP صحيح';

  @override
  String get enterFullName => 'أدخل الاسم الكامل*';

  @override
  String get gender => 'الجنس*';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get createPassword => 'إنشاء كلمة المرور*';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور*';

  @override
  String get pleaseSelectRelationship => 'يرجى اختيار العلاقة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get pickLocation => 'اختر الموقع';

  @override
  String get enterNumberOfKids => 'أدخل عدد الأطفال*';

  @override
  String get noOfBoys => 'عدد الأولاد*';

  @override
  String get noOfGirls => 'عدد البنات*';

  @override
  String get flat => 'شقة';

  @override
  String get villa => 'فيلا';

  @override
  String get office => 'مكتب';

  @override
  String get enterCity => 'أدخل مدينتك/منطقتك';

  @override
  String get enterBuilding => 'أدخل المبنى*';

  @override
  String get enterAptNo => 'أدخل رقم الشقة*';

  @override
  String get enterFloorNo => 'أدخل رقم الطابق*';

  @override
  String get selectBlock => 'اختر البلوك*';

  @override
  String get selectRoad => 'اختر الطريق*';

  @override
  String get pleaseSelectBlock => 'يرجى اختيار البلوك';

  @override
  String get pleaseSelectRoad => 'يرجى اختيار الطريق';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get accountCreatedSuccessfully => 'تم إنشاء الحساب بنجاح';

  @override
  String get submitFailed => 'فشل الإرسال';

  @override
  String get failedToLoadBlocks => 'فشل تحميل البلوكات';

  @override
  String addMemberTitle(Object accountType, Object current, Object total) {
    return 'إضافة عضو $accountType $current من $total';
  }

  @override
  String get enterFamilyCount => 'أدخل عدد أفراد العائلة*';

  @override
  String get addMemberBtn => 'إضافة عضو';

  @override
  String get memberFullName => 'الاسم الكامل للعضو*';

  @override
  String get relationship => 'العلاقة*';

  @override
  String get selectRelationship => 'اختر العلاقة';

  @override
  String get selectGender => 'اختر الجنس';

  @override
  String get hideAddress => 'إخفاء العنوان';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get finish => 'إنهاء';

  @override
  String get allMembersAdded => 'تمت إضافة جميع الأعضاء بنجاح';

  @override
  String get father => 'الأب';

  @override
  String get mother => 'الأم';

  @override
  String get son => 'الابن';

  @override
  String get daughter => 'الابنة';

  @override
  String get addOther => 'إضافة أخرى';

  @override
  String get husband => 'زوج';

  @override
  String get wife => 'زوجة';

  @override
  String get uploadIdTitle => 'تحميل بطاقة الهوية';

  @override
  String get uploadIdFrontTitle => 'الجانب الأمامي من بطاقة الهوية';

  @override
  String get uploadIdBackTitle => 'الجانب الخلفي من بطاقة الهوية';

  @override
  String get uploadIdSubtitle =>
      'تأكد من أن الاسم والصورة وتاريخ الانتهاء واضحة.';

  @override
  String get uploadIdError => 'يرجى تحميل كل من الصور الأمامية والخلفية';

  @override
  String get accountCreated => 'تم إنشاء الحساب';

  @override
  String get successfully => 'بنجاح!';

  @override
  String get accountCreatedDesc =>
      'مرحبًا بك في خدمات نادي البحرين. يمكنك الآن تسجيل الدخول إلى حسابك الجديد.';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get ourCommitments => 'التزاماتنا تجاهك';

  @override
  String get readFullTerms => 'اقرأ الشروط والأحكام كاملة';

  @override
  String get agreeTerms =>
      'لقد قرأت ووافقت على شروط وأحكام خدمة Connect وسياسة الخصوصية';

  @override
  String get completeRegistration => 'إكمال التسجيل';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMyRequest => 'طلباتي';

  @override
  String get navLiveChat => 'الدردشة المباشرة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get tapAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String get quickAction => 'إجراء سريع';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get serviceOverview => 'نظرة عامة على الخدمة';

  @override
  String get details => 'تفاصيل';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get createRequest => 'إنشاء طلب';

  @override
  String get addPoint => 'إضافة نقطة';

  @override
  String get approvalNeeded => 'الموافقة مطلوبة';

  @override
  String get technicianApprovalMessage =>
      'يريد الفني بدء العمل. يرجى الموافقة.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get youAreAllCaughtUp => 'لقد تم عرض جميع الإشعارات!';

  @override
  String get pointsDetails => 'تفاصيل النقاط';

  @override
  String get yourCurrentPointsBalance => 'رصيد النقاط الحالي';

  @override
  String get pointsRequests => 'طلبات النقاط:';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get adminRequests => 'طلبات المدير:';

  @override
  String get pointHistory => 'سجل النقاط:';

  @override
  String get noHistoryFound => 'لا يوجد سجل';

  @override
  String get noFamilyPointsFound => 'لا توجد نقاط عائلية';

  @override
  String get familyPoints => 'نقاط العائلة';

  @override
  String get myRecentActivity => 'نشاطي الأخير';

  @override
  String get requestToPoints => 'طلب نقاط';

  @override
  String get admin => 'المدير';

  @override
  String get friend => 'صديق';

  @override
  String get mobileNumber => 'رقم الجوال*';

  @override
  String get mobileNumberRequired => 'رقم الجوال مطلوب';

  @override
  String get enterValidMobile => 'أدخل رقم جوال صحيح';

  @override
  String get enterPoints => 'أدخل النقاط*';

  @override
  String get pointsRequired => 'النقاط مطلوبة';

  @override
  String get enterValidPoints => 'أدخل نقاط صحيحة';

  @override
  String get positiveIntegerHint => 'أدخل قيمة رقمية موجبة للنقاط.';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get notesHint => 'لطلب خدمة جديدة.';

  @override
  String get submit => 'إرسال';

  @override
  String get pointsRequestSuccess => 'تم إرسال طلب النقاط بنجاح';

  @override
  String get selectServiceIssue => 'يرجى اختيار الخدمة والمشكلة';

  @override
  String get createServiceRequest => 'إنشاء طلب خدمة';

  @override
  String get serviceCategory => 'فئة الخدمة';

  @override
  String get selectServices => 'اختر الخدمة*';

  @override
  String get servicePointsRequired => 'النقاط المطلوبة للخدمة';

  @override
  String get serviceFree => 'الخدمة مجانية';

  @override
  String pointsLabel(Object points) {
    return '$points نقطة';
  }

  @override
  String get issueDetails => 'تفاصيل المشكلة';

  @override
  String get selectIssue => 'اختر المشكلة*';

  @override
  String get describeIssue => 'صف مشكلتك…';

  @override
  String get mediaUploadOptional => 'تحميل الوسائط (اختياري)';

  @override
  String imagesSelectedCount(Object count) {
    return '$count / 10 صور مختارة';
  }

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String requestIdLabel(Object id) {
    return 'رقم الطلب: $id';
  }

  @override
  String get requestSuccessTitle => 'تم إرسال طلب الخدمة بنجاح.';

  @override
  String get requestSuccessDesc =>
      'تم استلام رقم الطلب الخاص بك وهو قيد المعالجة';

  @override
  String get viewMyRequest => 'عرض طلباتي';

  @override
  String get myServiceRequest => 'طلباتي للخدمات';

  @override
  String get noRequestFound => 'لا توجد طلبات';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get total => 'الإجمالي';

  @override
  String get serviceRequestDetails => 'تفاصيل طلب الخدمة';

  @override
  String get complaintDetails => 'تفاصيل الشكوى';

  @override
  String get feedback => 'الملاحظات';

  @override
  String get requestSubmitted => 'تم إرسال الطلب';

  @override
  String get requestSubmittedDesc => 'تم إرسال طلب الخدمة بنجاح.';

  @override
  String get adminProcessing => 'المشرف يعالج الطلب';

  @override
  String get adminProcessingDesc => 'يقوم فريق نادي بمراجعة تفاصيل طلبك.';

  @override
  String get technicianAssigned => 'تم تعيين الفني';

  @override
  String get technicianAssignedDesc => 'تم تعيين فني لطلبك.';

  @override
  String get serviceInProgress => 'الخدمة قيد التنفيذ';

  @override
  String get serviceInProgressDesc => 'الفني يعمل على خدمتك';

  @override
  String get paymentInProgress => 'تم إنجاز العمل التقني';

  @override
  String get paymentInProgressDesc => 'تم إنجاز العمل الفني';

  @override
  String get serviceCompleted => 'اكتملت الخدمة';

  @override
  String get serviceCompletedDesc => 'تم إكمال الخدمة بنجاح.';

  @override
  String get submitted => 'تم الإرسال';

  @override
  String get accepted => 'تم القبول';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get paymentPending => 'بانتظار الدفع';

  @override
  String get completed => 'مكتمل';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get close => 'إغلاق';

  @override
  String get toPay => 'المبلغ المطلوب';

  @override
  String get profileDetails => 'تفاصيل الملف الشخصي';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get noProfileData => 'لا توجد بيانات';

  @override
  String get errorLoadingProfile => 'خطأ في تحميل الملف';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get building => 'المبنى';

  @override
  String get city => 'المدينة';

  @override
  String get floor => 'الطابق';

  @override
  String get apartment => 'الشقة';

  @override
  String get additionalInfo => 'معلومات إضافية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get notification => 'الإشعارات';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get history => 'السجل';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String get helpSupportTitle => 'المساعدة والدعم';

  @override
  String get sendEnquiry => 'أرسل لنا استفسار';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get messageLabel => 'الرسالة';

  @override
  String get submitButton => 'إرسال';

  @override
  String get nameValidation => 'الرجاء إدخال الاسم';

  @override
  String get emailValidation => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get messageValidation => 'الرجاء إدخال الرسالة';

  @override
  String get enquirySuccess => 'تم إرسال الاستفسار بنجاح!';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneValidation => 'الرجاء إدخال رقم الهاتف';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountDescription => 'حدد سببًا قبل حذف حسابك:';

  @override
  String get delete => 'حذف';

  @override
  String get pleaseSelectReason => 'يرجى اختيار سبب';

  @override
  String get entertheEmail => 'أدخل البريد الإلكتروني';

  @override
  String get invalidEmail => 'تنسيق البريد الإلكتروني غير صالح';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get enterPhone => 'أدخل رقم الهاتف';

  @override
  String get invalidPhoneLength => 'يجب أن يكون رقم الهاتف 8 أرقام';

  @override
  String get onlyDigitsAllowed => 'يسمح بالأرقام فقط';

  @override
  String get fullNameRequired => 'الاسم الأول مطلوب';

  @override
  String get addAddressError => 'يرجى إضافة العنوان';

  @override
  String get mobileMustBe8Digits => 'يجب أن يكون رقم الجوال 8 أرقام';

  @override
  String get enterConfirmPassword => 'أدخل تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get enterMobile => 'أدخل رقم الجوال';

  @override
  String get invalidCountryCode => 'رمز الدولة غير صحيح';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟';

  @override
  String get notificationUpdateFailed => 'فشل في تحديث إعدادات الإشعارات';

  @override
  String get title => 'حذف الإشعار';

  @override
  String get message => 'هل أنت متأكد أنك تريد حذف هذا الإشعار؟';

  @override
  String get messageAll => 'هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟';

  @override
  String get family => 'عائلة';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get accountDisabled => 'تم تعطيل الحساب';

  @override
  String get accountDisabledMsg => 'تم تعطيل حسابك. يرجى التواصل مع الدعم.';

  @override
  String get accountRejected => 'تم رفض الحساب';

  @override
  String get accountRejectedMsg => 'تم رفض تسجيل حسابك. يرجى التواصل مع الدعم.';

  @override
  String get invalidCredentials => 'بيانات تسجيل الدخول غير صحيحة';

  @override
  String get ok => 'حسناً';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get familyMembers => 'أفراد العائلة';

  @override
  String get noFamilyMembers =>
      'لا يوجد أفراد عائلة حتى الآن. اضغط على \"إضافة عضو\" لدعوة شخص.';

  @override
  String get active => 'نشط';

  @override
  String get rejected => 'مرفوض';

  @override
  String get removeMemberTitle => 'إزالة فرد من العائلة';

  @override
  String get removeMemberMessage =>
      'هل أنت متأكد أنك تريد إزالة هذا العضو من العائلة؟ لن يتمكن بعد الآن من مشاركة النقاط مع العائلة.';

  @override
  String get remove => 'إزالة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String memberRemoved(Object name) {
    return 'تمت إزالة $name من العائلة';
  }

  @override
  String get feedbackSubmittedSuccessfully => 'تم إرسال الملاحظات بنجاح';

  @override
  String get failedToSubmitFeedback => 'فشل إرسال الملاحظات';

  @override
  String get writeYourFeedback => 'اكتب ملاحظاتك...';

  @override
  String get somethingWentWrongTryAgain =>
      'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get unexpectedErrorOccurred => 'حدث خطأ غير متوقع';

  @override
  String get chat => 'الدردشة';

  @override
  String get couldNotLoadChat => 'تعذر تحميل الدردشة';

  @override
  String get checkConnectionTryAgain =>
      'يرجى التحقق من الاتصال والمحاولة مرة أخرى.';

  @override
  String get writeMessage => 'اكتب رسالة...';

  @override
  String get block => 'بلوك';

  @override
  String get thisMember => 'هذا العضو';

  @override
  String get saveChangesTitle => 'حفظ التغييرات؟';

  @override
  String get saveChangesMessage =>
      'هل أنت متأكد أنك تريد حفظ التغييرات على ملفك الشخصي؟';

  @override
  String get selectFamilyMember => 'اختر فرد العائلة';

  @override
  String get noFamilyMembersFound => 'لم يتم العثور على أفراد عائلة';

  @override
  String get chooseMember => 'اختر عضوًا';

  @override
  String get pleaseSelectFamilyMember => 'يرجى اختيار فرد من العائلة';

  @override
  String get pleaseAnswerBeforeNext =>
      'يرجى الإجابة قبل الانتقال للسؤال التالي';

  @override
  String get qaConversation => 'محادثة الأسئلة والأجوبة';

  @override
  String get noAdminQuestions => 'لا توجد أسئلة من الإدارة';

  @override
  String get noQuestionsAvailable => 'لا توجد أسئلة متاحة';

  @override
  String questionProgress(Object current, Object total) {
    return 'السؤال $current من $total';
  }

  @override
  String get enterYourAnswer => 'أدخل إجابتك';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get success => 'تم بنجاح!';

  @override
  String pointsEarnedLabel(Object points) {
    return '+ $points نقطة مكتسبة';
  }

  @override
  String totalPointsLabel(Object total) {
    return 'إجمالي النقاط: $total';
  }

  @override
  String get done => 'تم';

  @override
  String get completedExclamation => 'اكتمل!';

  @override
  String get discardSignUpTitle => 'إلغاء التسجيل؟';

  @override
  String get discardSignUpMessage =>
      'هل أنت متأكد أنك تريد المغادرة؟ ستفقد جميع المعلومات التي أدخلتها.';

  @override
  String get discard => 'إلغاء';

  @override
  String get member => 'العضو';

  @override
  String get account => 'الحساب';

  @override
  String accountTypeStepperTitle(Object accountType) {
    return 'حساب $accountType';
  }

  @override
  String get memberAddedSuccessfully => 'تمت إضافة العضو بنجاح';

  @override
  String get connectionTimeoutTryAgain =>
      'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت والمحاولة مرة أخرى.';

  @override
  String get noInternetTryAgain =>
      'لا يوجد اتصال بالإنترنت. يرجى المحاولة مرة أخرى.';

  @override
  String get sessionEnded => 'انتهت الجلسة';

  @override
  String get sessionEndedMessage => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get accountDisabledSupportMessage =>
      'تم تعطيل حسابك. يرجى التواصل مع فريق الدعم للمساعدة.';

  @override
  String get accountRejectedSupportMessage =>
      'تم رفض حسابك. يرجى التواصل مع فريق الدعم للمساعدة.';

  @override
  String get noContent => 'لا يوجد محتوى';

  @override
  String get noContentAvailable => 'لا يوجد محتوى متاح';

  @override
  String versionLabel(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get noChatsFound => 'لا توجد محادثات';

  @override
  String get chats => 'المحادثات';

  @override
  String get searchMessage => 'ابحث في الرسائل...';

  @override
  String get resetEmailSentCheckInbox =>
      'تم إرسال رسالة إعادة التعيين! يرجى التحقق من بريدك الوارد.';

  @override
  String get passwordResetSuccessful =>
      'تمت إعادة تعيين كلمة المرور بنجاح! يرجى تسجيل الدخول.';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordInstructions =>
      'افتح رسالة إعادة التعيين التي وصلتك، ثم انسخ الرمز الموجود في نهاية الرابط والصقه أدناه.';

  @override
  String get resetTokenFromEmail => 'رمز إعادة التعيين (من البريد الإلكتروني)';

  @override
  String get enterResetTokenFromEmail =>
      'يرجى إدخال رمز إعادة التعيين من البريد الإلكتروني';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get back => 'رجوع';

  @override
  String get photo => 'صورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get uploadGallery => 'رفع من المعرض';

  @override
  String get englishShort => 'Eng';

  @override
  String get arabicShort => 'عربي';

  @override
  String get recording => 'جارٍ التسجيل...';

  @override
  String get recordVoice => 'تسجيل صوت';

  @override
  String get recordedVoice => 'الصوت المسجل';

  @override
  String get noServiceRequestIdFound => 'لم يتم العثور على رقم طلب الخدمة';

  @override
  String get noRequestsFound => 'لا توجد طلبات';

  @override
  String get enterPointsValue => 'أدخل النقاط';

  @override
  String get send => 'إرسال';

  @override
  String get noRecentActivity => 'لا يوجد نشاط حديث';

  @override
  String get errorLabel => 'خطأ';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get spouse => 'الزوج/الزوجة';

  @override
  String get pleaseSelectOption => 'يرجى اختيار أحد الخيارات';

  @override
  String get pleaseEnterYourAnswer => 'يرجى إدخال إجابتك';

  @override
  String get individual => 'فردي';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get secondName => 'الاسم الثاني';

  @override
  String get thirdName => 'الاسم الثالث';

  @override
  String get fourthName => 'اسم العائلة';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get failedToAddMemberTryAgain =>
      'فشل إضافة العضو. يرجى المحاولة مرة أخرى.';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get more => 'المزيد';

  @override
  String get apartmentRequired => 'رقم الشقة مطلوب';

  @override
  String get apartmentInvalid => 'يرجى إدخال رقم شقة صحيح';

  @override
  String get maximum10ImagesAllowed => 'يسمح بحد أقصى 10 صور';

  @override
  String get emailPhoneRequired => 'البريد الإلكتروني أو رقم الهاتف مطلوب';

  @override
  String get invalidEmailOrPhone =>
      'أدخل بريدًا إلكترونيًا صالحًا أو رقم هاتف مكون من 8 أرقام';

  @override
  String get enterValidEmail => 'أدخل بريد إلكتروني صالح';

  @override
  String get pleaseFillMemberDetails => 'يرجى ملء تفاصيل العضو';

  @override
  String get mobileNumberMustBe8Digits => 'يجب أن يكون رقم الجوال 8 أرقام';

  @override
  String get enterfirstname => 'أدخل الاسم الأول';

  @override
  String get enteryour_build => 'أدخل اسم المبنى';

  @override
  String get enteraptno => 'أدخل رقم الشقة';

  @override
  String get enterFloorno => 'أدخل رقم الطابق';

  @override
  String get enter_memberFullName => 'أدخل اسم العضو بالكامل';

  @override
  String get buildingRequired => 'المبنى مطلوب';

  @override
  String get floorRequired => 'رقم الطابق مطلوب';

  @override
  String get pleaseEnterOtp => 'يرجى إدخال رمز التحقق';

  @override
  String get otpMustBe4Digits => 'يجب أن يتكون رمز التحقق من 4 أرقام';

  @override
  String get ofText => 'من';

  @override
  String get added => 'تمت الإضافة';

  @override
  String get pleaseFillCurrentMemberFirst =>
      'يمكنك تحديث عدد أفراد الأسرة بعد إدخال جميع تفاصيل الأعضاء وقبل الإرسال.';

  @override
  String get familyCountMustBeGreaterThanZero =>
      'يجب أن يكون عدد أفراد العائلة أكبر من 0';

  @override
  String get maximumFamilyCountIs => 'الحد الأقصى لعدد أفراد العائلة هو 10';

  @override
  String get userIdNotFound => 'معرّف المستخدم غير موجود';

  @override
  String get completeCurrentMemberBeforeContinue =>
      'يرجى إكمال بيانات العضو الحالي قبل المتابعة';

  @override
  String get home => 'منزل';

  @override
  String get pleaseEnterBlock => 'يرجى إدخال اسم المجمع';

  @override
  String get pleaseEnterRoad => 'يرجى إدخال اسم الشارع';

  @override
  String duplicateEmailWithMember(Object member) {
    return 'عنوان البريد الإلكتروني هذا مستخدم بالفعل من قبل العضو رقم $member. يرجى استخدام بريد إلكتروني مختلف.';
  }

  @override
  String duplicateMobileWithMember(Object member) {
    return 'رقم الهاتف هذا مستخدم بالفعل من قبل العضو رقم $member. يرجى استخدام رقم هاتف مختلف.';
  }

  @override
  String get fieldCannotBeEmpty => 'هذا الحقل لا يمكن أن يكون فارغاً';

  @override
  String get pleaseSelectAnOption => 'يرجى اختيار خيار';

  @override
  String get pleaseEnableLocationService => 'يرجى تفعيل خدمة الموقع';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionPermanentlyDenied =>
      'تم رفض إذن الموقع بشكل دائم';

  @override
  String get useFamilyHeaderAddress => 'استخدام عنوان رب الأسرة';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get enterManually => 'إدخال يدوي';

  @override
  String get others => 'أخرى';

  @override
  String get enterBlockName => 'أدخل اسم المجمع';

  @override
  String get pleaseEnterBlockName => 'يرجى إدخال اسم المجمع';

  @override
  String get enterRoadName => 'أدخل اسم الطريق';

  @override
  String get pleaseEnterRoadName => 'يرجى إدخال اسم الطريق';

  @override
  String get selectedAddressLabel => 'العنوان المحدد:';

  @override
  String get editLocation => 'تعديل الموقع';

  @override
  String get enterFamilyCountFirst => 'أدخل عدد أفراد العائلة أولاً';

  @override
  String get accountAlreadyExists => 'الحساب موجود بالفعل';

  @override
  String get sessionExpiredLoginAgain =>
      'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get supportPhoneNumber => '+973 17000000';

  @override
  String get supportEmail => 'support@nadibh.com';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get searchAddress => 'ابحث عن عنوان';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get failedToResendOtp => 'فشل في إعادة إرسال رمز التحقق';

  @override
  String get registrationSuccessfulWaitVerification =>
      'تم التسجيل بنجاح. يرجى انتظار التحقق.';

  @override
  String get invalidOtp => 'رمز التحقق غير صالح';

  @override
  String get accountRejectedRegistrationMessage =>
      'تم رفض تسجيل حسابك. يرجى التواصل مع فريق الدعم لمزيد من المعلومات.';

  @override
  String get noTermsAvailable => 'لا تتوفر شروط وأحكام في الوقت الحالي.';

  @override
  String get failedToLoadTerms =>
      'فشل تحميل الشروط والأحكام. يرجى المحاولة لاحقاً.';

  @override
  String get chooseTheLanguage => 'اختر اللغة';

  @override
  String get englishLanguage => 'الإنجليزية';

  @override
  String get languagePreferenceChangeHint =>
      'يمكنك تغيير تفضيل اللغة في أي وقت من الإعدادات';

  @override
  String get submittedSuccessfully => 'تم الإرسال بنجاح';

  @override
  String get unknownMember => 'غير معروف';

  @override
  String get serviceTitle => 'الخدمة';

  @override
  String get workApprovedSuccessfully => 'تمت الموافقة على العمل بنجاح';

  @override
  String get workRejectedSuccessfully => 'تم رفض العمل بنجاح';

  @override
  String get questionPopupBarrierLabel => 'نافذة الأسئلة';

  @override
  String get ongoingStatus => 'جاري التنفيذ';

  @override
  String get addressTypeLabel => 'نوع العنوان';

  @override
  String addressTypeWithValue(Object type) {
    return 'نوع العنوان: $type';
  }

  @override
  String get fullLocationAddressLabel => 'عنوان الموقع الكامل';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get noHelpDataAvailable => 'لا تتوفر بيانات مساعدة';

  @override
  String get maximum10ImagesUpload => 'يمكنك رفع 10 صور كحد أقصى';

  @override
  String get serviceRequestSubmittedSuccess => 'تم إرسال طلب الخدمة\nبنجاح.';

  @override
  String get serviceRequestReceivedProcessing =>
      'تم استلام طلبك (SRM-001)\nوهو قيد المعالجة.';

  @override
  String get settingsSectionGeneral => 'عام';

  @override
  String get settingsSectionPreferences => 'التفضيلات';

  @override
  String get settingsSectionAccount => 'الحساب';

  @override
  String get languageBhAbbrev => 'عربي';

  @override
  String get languageEngAbbrev => 'ENG';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get congratulations => 'تهانينا!';

  @override
  String get claimReward => 'استلام المكافأة';

  @override
  String get exitAppConfirmation => 'هل تريد الخروج من التطبيق؟';

  @override
  String get exit => 'خروج';

  @override
  String get addMedia => 'إضافة وسائط';

  @override
  String get noInternetConnectionTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetConnectionMessage =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get pointsToYou => 'نقاط إليك';

  @override
  String pointsFromName(Object name) {
    return 'نقاط من $name';
  }

  @override
  String get accept => 'قبول';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get requestAccepted => 'تم قبول الطلب';

  @override
  String get requestRejected => 'تم رفض الطلب';

  @override
  String get microphonePermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get familyHeaderAddressLabel => 'عنوان رب الأسرة';

  @override
  String get currentLocationLabel => 'الموقع الحالي';

  @override
  String get manualAddressLabel => 'عنوان يدوي';

  @override
  String get genericAddressLabel => 'العنوان';

  @override
  String cityWithValue(Object value) {
    return 'المدينة $value';
  }

  @override
  String buildingWithValue(Object value) {
    return 'المبنى $value';
  }

  @override
  String apartmentWithValue(Object value) {
    return 'الشقة $value';
  }

  @override
  String floorWithValue(Object value) {
    return 'الطابق $value';
  }

  @override
  String blockWithValue(Object value) {
    return 'المجمع $value';
  }

  @override
  String roadWithValue(Object value) {
    return 'الطريق $value';
  }
}
