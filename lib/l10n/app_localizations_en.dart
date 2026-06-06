// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get skip => 'Skip';

  @override
  String get nadiBahrainServices => 'Nadi Bahrain Services';

  @override
  String get welcome => 'Welcome!';

  @override
  String get getStarted => 'Get Started';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signInWithOtp => 'Sign In with OTP';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'OR';

  @override
  String get changePassword => 'Change your Password';

  @override
  String get enterEmail => 'Enter Email';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get emailSentMessage => 'Email sent successfully';

  @override
  String get enterVerificationCode => 'Enter Verification code';

  @override
  String get otpSentMessage =>
      'We have sent you a 4 digit verification code on';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendOtpIn(Object seconds) {
    return 'Resend OTP in 00:$seconds';
  }

  @override
  String get otpSignIn => 'Sign In';

  @override
  String get enter4DigitOtp => 'Please enter 4 digit OTP';

  @override
  String get accountTypeTitle => 'Account Type';

  @override
  String get individualAccount => 'Individual Account';

  @override
  String get individualAccountDesc =>
      'Manage your services and profile independently.';

  @override
  String get familyAccount => 'Family Account';

  @override
  String get familyAccountDesc =>
      'Register and manage services for multiple family members.';

  @override
  String get signUpTitle => 'Sign up';

  @override
  String get accountVerificationTitle =>
      'Secure Your Account With ID Verification';

  @override
  String get accountVerificationDesc1 =>
      'To ensure the highest level of security and trust within the Service Connect community, we require all users to complete a simple identity verification process. This helps protect against fraud and maintain a safe environment for everyone.';

  @override
  String get accountVerificationDesc2 =>
      'We value your safety and privacy. Your information is securely processed and used only for verification purposes.';

  @override
  String get continueButton => 'Continue';

  @override
  String get enterPhoneNumber => 'Enter Phone Number';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get phoneMustBe8Digits => 'Phone number must be 8 digits';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get enterValidOtp => 'Enter valid OTP';

  @override
  String get enterFullName => 'Enter Full Name*';

  @override
  String get gender => 'Gender*';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get createPassword => 'Create Password*';

  @override
  String get confirmPassword => 'Confirm Password*';

  @override
  String get pleaseSelectRelationship => 'Please select relationship';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get pickLocation => 'Pick Location';

  @override
  String get enterNumberOfKids => 'Enter Number of kids*';

  @override
  String get noOfBoys => 'No of boys*';

  @override
  String get noOfGirls => 'No of girls*';

  @override
  String get flat => 'Flat';

  @override
  String get villa => 'Villa';

  @override
  String get office => 'Office';

  @override
  String get enterCity => 'Enter Your city/Area';

  @override
  String get enterBuilding => 'Enter Your Building*';

  @override
  String get enterAptNo => 'Enter Apt No*';

  @override
  String get enterFloorNo => 'Enter Floor No*';

  @override
  String get selectBlock => 'Select Your Block*';

  @override
  String get selectRoad => 'Select Your Road*';

  @override
  String get pleaseSelectBlock => 'Please select a block';

  @override
  String get pleaseSelectRoad => 'Please select a road';

  @override
  String get continueBtn => 'Continue';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully';

  @override
  String get submitFailed => 'Submit failed';

  @override
  String get failedToLoadBlocks => 'Failed to load blocks';

  @override
  String addMemberTitle(Object accountType, Object current, Object total) {
    return 'Add $accountType Member $current of $total';
  }

  @override
  String get enterFamilyCount => 'Enter Family Count*';

  @override
  String get addMemberBtn => 'Add Member';

  @override
  String get memberFullName => 'Member Full Name*';

  @override
  String get relationship => 'Relationship*';

  @override
  String get selectRelationship => 'Select relationship';

  @override
  String get selectGender => 'Select gender';

  @override
  String get hideAddress => 'Hide Address';

  @override
  String get addAddress => 'Add Address';

  @override
  String get finish => 'Finish';

  @override
  String get allMembersAdded => 'All members added successfully';

  @override
  String get father => 'Father';

  @override
  String get mother => 'Mother';

  @override
  String get son => 'Son';

  @override
  String get daughter => 'Daughter';

  @override
  String get addOther => 'Add Other';

  @override
  String get husband => 'Husband';

  @override
  String get wife => 'Wife';

  @override
  String get uploadIdTitle => 'Upload ID Card';

  @override
  String get uploadIdFrontTitle => 'Front Side of ID Card';

  @override
  String get uploadIdBackTitle => 'Back Side of ID Card';

  @override
  String get uploadIdSubtitle =>
      'Ensure your name, photo, and expiry date are clearly visible.';

  @override
  String get uploadIdError => 'Please upload both front and back images';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get successfully => 'Successfully!';

  @override
  String get accountCreatedDesc =>
      'Welcome to Nadi Bahrain Services. You can now sign in to your new account.';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get ourCommitments => 'Our Commitments To You';

  @override
  String get readFullTerms => 'Read the full Terms & Conditions';

  @override
  String get agreeTerms =>
      'I have read and agree to the Service Connect Terms & Conditions and Privacy Policy';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get navHome => 'Home';

  @override
  String get navMyRequest => 'My Request';

  @override
  String get navLiveChat => 'Live Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get tapAgainToExit => 'Tap again to exit';

  @override
  String get quickAction => 'Quick Action';

  @override
  String get viewAll => 'View All';

  @override
  String get serviceOverview => 'Service Overview';

  @override
  String get details => 'Details';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get createRequest => 'Create Request';

  @override
  String get addPoint => 'Add point';

  @override
  String get approvalNeeded => 'Approval Needed';

  @override
  String get technicianApprovalMessage =>
      'Technician wants to start the work. Kindly approve.';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get youAreAllCaughtUp => 'You\'re all caught up!';

  @override
  String get pointsDetails => 'Points Details';

  @override
  String get yourCurrentPointsBalance => 'Your Current Points Balance';

  @override
  String get pointsRequests => 'Points Requests:';

  @override
  String get showMore => 'Show More';

  @override
  String get adminRequests => 'Admin Requests:';

  @override
  String get pointHistory => 'Point History:';

  @override
  String get noHistoryFound => 'No History Found';

  @override
  String get noFamilyPointsFound => 'No Family Points Found';

  @override
  String get familyPoints => 'Family Points';

  @override
  String get myRecentActivity => 'My Recent Activity';

  @override
  String get requestToPoints => 'Request To Points';

  @override
  String get admin => 'Admin';

  @override
  String get friend => 'Friend';

  @override
  String get mobileNumber => 'Mobile Number*';

  @override
  String get mobileNumberRequired => 'Mobile number required';

  @override
  String get enterValidMobile => 'Enter valid mobile number';

  @override
  String get enterPoints => 'Enter Points*';

  @override
  String get pointsRequired => 'Points required';

  @override
  String get enterValidPoints => 'Enter valid points';

  @override
  String get positiveIntegerHint =>
      'Enter a positive integer value for the points.';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get notesHint => 'For new service request.';

  @override
  String get submit => 'Submit';

  @override
  String get pointsRequestSuccess => 'Points request sent successfully';

  @override
  String get selectServiceIssue => 'Please select service & issue';

  @override
  String get createServiceRequest => 'Create Service Request';

  @override
  String get serviceCategory => 'Service category';

  @override
  String get selectServices => 'Select Services*';

  @override
  String get servicePointsRequired => 'Service Points Required';

  @override
  String get serviceFree => 'Service Free';

  @override
  String pointsLabel(Object points) {
    return '$points Points';
  }

  @override
  String get issueDetails => 'Issue Details';

  @override
  String get selectIssue => 'Select Issue*';

  @override
  String get describeIssue => 'Describe your issue…';

  @override
  String get mediaUploadOptional => 'Media Upload (optional)';

  @override
  String imagesSelectedCount(Object count) {
    return '$count / 10 images selected';
  }

  @override
  String get sendRequest => 'Send Request';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String requestIdLabel(Object id) {
    return 'Request ID: $id';
  }

  @override
  String get requestSuccessTitle => 'Service request submitted successfully.';

  @override
  String get requestSuccessDesc =>
      'Your request id has been received and is being processed';

  @override
  String get viewMyRequest => 'View My Request';

  @override
  String get myServiceRequest => 'MY Service Request';

  @override
  String get noRequestFound => 'No request found';

  @override
  String get viewDetails => 'View Details';

  @override
  String get total => 'Total';

  @override
  String get serviceRequestDetails => 'Service Request Details';

  @override
  String get complaintDetails => 'Complaint Details';

  @override
  String get feedback => 'Feedback';

  @override
  String get requestSubmitted => 'Request Submitted';

  @override
  String get requestSubmittedDesc =>
      'Your service request has been successfully submitted.';

  @override
  String get adminProcessing => 'Admin Processing Request';

  @override
  String get adminProcessingDesc =>
      'Nadi team is reviewing the details of your request.';

  @override
  String get technicianAssigned => 'Technician Assigned';

  @override
  String get technicianAssignedDesc =>
      'A technician has been assigned to your request.';

  @override
  String get serviceInProgress => 'Service In Progress';

  @override
  String get serviceInProgressDesc => 'Technician is working on your service';

  @override
  String get paymentInProgress => 'Tech work completed';

  @override
  String get paymentInProgressDesc => 'Technician work completed';

  @override
  String get serviceCompleted => 'Service Completed';

  @override
  String get serviceCompletedDesc => 'Service has been successfully completed.';

  @override
  String get submitted => 'Submitted';

  @override
  String get accepted => 'Accepted';

  @override
  String get inProgress => 'In Progress';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get completed => 'Completed';

  @override
  String get pending => 'Pending';

  @override
  String get close => 'Close';

  @override
  String get toPay => 'To Pay';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get loading => 'Loading...';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get noProfileData => 'No profile data';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get building => 'Building';

  @override
  String get city => 'City';

  @override
  String get floor => 'Floor';

  @override
  String get apartment => 'Apartment';

  @override
  String get additionalInfo => 'Additional Info';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get aboutApp => 'About App';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get notification => 'Notification';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get history => 'History';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get logout => 'Log Out';

  @override
  String get accountDelete => 'Account Delete';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get sendEnquiry => 'Send us an Enquiry';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get messageLabel => 'Message';

  @override
  String get submitButton => 'Submit';

  @override
  String get nameValidation => 'Please enter your name';

  @override
  String get emailValidation => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get messageValidation => 'Please enter a message';

  @override
  String get enquirySuccess => 'Enquiry submitted successfully!';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneValidation => 'Please enter your phone number';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountDescription =>
      'Select a reason before deleting your account:';

  @override
  String get delete => 'Delete';

  @override
  String get pleaseSelectReason => 'Please select a reason';

  @override
  String get entertheEmail => 'Enter the email';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get enterPassword => 'Enter the password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get enterPhone => 'Enter the mobile number';

  @override
  String get invalidPhoneLength => 'Mobile must be 8 digits';

  @override
  String get onlyDigitsAllowed => 'Only digits allowed';

  @override
  String get fullNameRequired => 'FirstName is required';

  @override
  String get addAddressError => 'Please add address';

  @override
  String get mobileMustBe8Digits => 'Mobile must be 8 digits';

  @override
  String get enterConfirmPassword => 'Enter confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get enterMobile => 'Enter mobile number';

  @override
  String get invalidCountryCode => 'Invalid country code';

  @override
  String get logoutTitle => 'Log Out';

  @override
  String get logoutMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get notificationUpdateFailed =>
      'Failed to update notification setting';

  @override
  String get title => 'Delete Notification';

  @override
  String get message => 'Are you sure you want to delete this notification?';

  @override
  String get family => 'Family';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password required';

  @override
  String get accountDisabled => 'Account Disabled';

  @override
  String get accountDisabledMsg =>
      'Your account has been disabled. Please contact support.';

  @override
  String get accountRejected => 'Account Rejected';

  @override
  String get accountRejectedMsg =>
      'Your account registration has been rejected.';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get ok => 'OK';

  @override
  String get addMember => 'Add Member';

  @override
  String get familyMembers => 'Family Members';

  @override
  String get noFamilyMembers =>
      'No family members yet. Tap \"Add Member\" to invite someone.';

  @override
  String get active => 'Active';

  @override
  String get rejected => 'Rejected';

  @override
  String get removeMemberTitle => 'Remove Family Member';

  @override
  String get removeMemberMessage =>
      'Are you sure you want to remove this member from your family? They will no longer be able to share points with the family.';

  @override
  String get remove => 'Remove';

  @override
  String get retry => 'Retry';

  @override
  String memberRemoved(Object name) {
    return '$name removed from family';
  }

  @override
  String get feedbackSubmittedSuccessfully => 'Feedback submitted successfully';

  @override
  String get failedToSubmitFeedback => 'Failed to submit feedback';

  @override
  String get writeYourFeedback => 'Write your feedback...';

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';

  @override
  String get unexpectedErrorOccurred => 'Unexpected error occurred';

  @override
  String get chat => 'Chat';

  @override
  String get couldNotLoadChat => 'Could not load chat';

  @override
  String get checkConnectionTryAgain =>
      'Please check your connection and try again.';

  @override
  String get writeMessage => 'Write a message...';

  @override
  String get block => 'Block';

  @override
  String get thisMember => 'this member';

  @override
  String get saveChangesTitle => 'Save changes?';

  @override
  String get saveChangesMessage =>
      'Are you sure you want to save the changes to your profile?';

  @override
  String get selectFamilyMember => 'Select Family Member';

  @override
  String get noFamilyMembersFound => 'No family members found';

  @override
  String get chooseMember => 'Choose a member';

  @override
  String get pleaseSelectFamilyMember => 'Please select a family member';

  @override
  String get pleaseAnswerBeforeNext => 'Please answer before moving next';

  @override
  String get qaConversation => 'Q & A Conversation';

  @override
  String get noAdminQuestions => 'No admin questions';

  @override
  String get noQuestionsAvailable => 'No questions available';

  @override
  String questionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get enterYourAnswer => 'Enter your answer';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get success => 'Success!';

  @override
  String pointsEarnedLabel(Object points) {
    return '+ $points Points Earned';
  }

  @override
  String totalPointsLabel(Object total) {
    return 'Total Points: $total';
  }

  @override
  String get done => 'Done';

  @override
  String get completedExclamation => 'Completed!';

  @override
  String get discardSignUpTitle => 'Discard Sign Up?';

  @override
  String get discardSignUpMessage =>
      'Are you sure you want to leave? Any information you\'ve entered will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get member => 'Member';

  @override
  String get account => 'Account';

  @override
  String accountTypeStepperTitle(Object accountType) {
    return '$accountType Account';
  }

  @override
  String get memberAddedSuccessfully => 'Member added successfully';

  @override
  String get connectionTimeoutTryAgain =>
      'Connection timeout. Please check your internet and try again.';

  @override
  String get noInternetTryAgain => 'No internet connection. Please try again.';

  @override
  String get sessionEnded => 'Session Ended';

  @override
  String get sessionEndedMessage =>
      'Your session has ended. Please sign in again.';

  @override
  String get accountDisabledSupportMessage =>
      'Your account has been disabled. Please contact our support team for assistance.';

  @override
  String get accountRejectedSupportMessage =>
      'Your account has been rejected. Please contact our support team for assistance.';

  @override
  String get noContent => 'No content';

  @override
  String get noContentAvailable => 'No content available';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get noChatsFound => 'No chats found';

  @override
  String get chats => 'Chats';

  @override
  String get searchMessage => 'Search Message...';

  @override
  String get resetEmailSentCheckInbox =>
      'Reset email sent! Please check your inbox.';

  @override
  String get passwordResetSuccessful =>
      'Password reset successful! Please log in.';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordInstructions =>
      'Open the reset email you received, copy the token at the end of the link, and paste it below.';

  @override
  String get resetTokenFromEmail => 'Reset Token (from email)';

  @override
  String get enterResetTokenFromEmail =>
      'Please enter the reset token from email';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get back => 'Back';

  @override
  String get photo => 'Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get uploadGallery => 'Upload Gallery';

  @override
  String get englishShort => 'Eng';

  @override
  String get arabicShort => 'عربي';

  @override
  String get recording => 'Recording...';

  @override
  String get recordVoice => 'Record Voice';

  @override
  String get recordedVoice => 'Recorded Voice';

  @override
  String get noServiceRequestIdFound => 'No Service Request ID found';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get enterPointsValue => 'Enter points';

  @override
  String get send => 'Send';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get errorLabel => 'Error';

  @override
  String get notAvailable => 'N/A';

  @override
  String get spouse => 'Spouse';

  @override
  String get pleaseSelectOption => 'Please select an option';

  @override
  String get pleaseEnterYourAnswer => 'Please enter your answer';

  @override
  String get individual => 'Individual';

  @override
  String get firstName => 'First Name';

  @override
  String get secondName => 'Second Name';

  @override
  String get thirdName => 'Third Name';

  @override
  String get fourthName => 'Fourth Name';

  @override
  String get requiredField => 'Required';

  @override
  String get failedToAddMemberTryAgain =>
      'Failed to add member. Please try again.';

  @override
  String get emailOrPhone => 'Email / Phone Number';

  @override
  String get more => 'More..';

  @override
  String get apartmentRequired => 'Apartment is required';

  @override
  String get apartmentInvalid => 'Please enter valid apartment';

  @override
  String get maximum10ImagesAllowed => 'Maximum 10 images allowed';

  @override
  String get emailPhoneRequired => 'Email or phone number is required';

  @override
  String get invalidEmailOrPhone => 'Enter valid email or 8-digit phone number';

  @override
  String get enterValidEmail => 'Enter valid email address';

  @override
  String get pleaseFillMemberDetails => 'Please fill the member details';

  @override
  String get mobileNumberMustBe8Digits =>
      'Mobile number must be exactly 8 digits';

  @override
  String get enterfirstname => 'Enter first name';

  @override
  String get enteryour_build => 'Enter your building';

  @override
  String get enteraptno => 'Enter apt no';

  @override
  String get enterFloorno => 'Enter floor no';

  @override
  String get enter_memberFullName => 'Enter member full name';

  @override
  String get buildingRequired => 'Building is required';

  @override
  String get floorRequired => 'Floor number is required';

  @override
  String get pleaseEnterOtp => 'Please enter OTP';

  @override
  String get otpMustBe4Digits => 'OTP must be 4 digits';

  @override
  String get ofText => 'of';

  @override
  String get added => 'Added';

  @override
  String get pleaseFillCurrentMemberFirst =>
      'You can update the family count after entering all member details and before submitting.';

  @override
  String get familyCountMustBeGreaterThanZero =>
      'Family count must be greater than 0';

  @override
  String get maximumFamilyCountIs => 'Maximum family count is 10';

  @override
  String get userIdNotFound => 'User ID not found';

  @override
  String get completeCurrentMemberBeforeContinue =>
      'Please complete current member before continuing';

  @override
  String get home => 'Home';

  @override
  String get pleaseEnterBlock => 'Please enter block';

  @override
  String get pleaseEnterRoad => 'Please enter road';
}
