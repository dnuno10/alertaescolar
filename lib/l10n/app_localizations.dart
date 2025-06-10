import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    if (localizations != null) {
      return localizations;
    }

    // Fallback to English if localizations are not found
    if (kDebugMode) {
      print(
          'Warning: No AppLocalizations found in context. Using English fallback. '
          'Make sure to include AppLocalizations.delegate in your app\'s localizationsDelegates.');
    }
    return AppLocalizationsEn();
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  // Basic app strings
  String get appTitle => 'School Alert';
  String get homeTitle => 'Dashboard';
  String get attendance => 'Attendance';
  String get notifications => 'Notifications';
  String get profile => 'Profile';
  String get students => 'Students';
  String get settings => 'Settings';
  String get darkMode => 'Dark Mode';
  String get language => 'Language';
  String get spanish => 'Spanish';
  String get english => 'English';
  String get welcome => 'Welcome';
  String get goodMorning => 'Good morning';
  String get goodAfternoon => 'Good afternoon';
  String get goodEvening => 'Good evening';
  String get viewAll => 'View All';
  String get present => 'Present';
  String get absent => 'Absent';
  String get late => 'Late';
  String get today => 'Today';
  String get cancel => 'Cancel';
  String get close => 'Close';
  String get undo => 'Undo';
  String get save => 'Save';
  String get edit => 'Edit';
  String get delete => 'Delete';
  String get add => 'Add';
  String get grade => 'Grade';
  String get noData => 'No data';

  // Students
  String get addStudent => 'Add Student';
  String get studentName => 'Student Name';
  String get studentGrade => 'Grade';
  String get noStudentsTitle => 'No students registered';
  String get noStudentsMessage =>
      'Register your children to start monitoring their school activity';
  String get noStudents => 'No Students';
  String get addFirstStudent => 'Add your first student';

  // Notifications
  String get noNotifications => 'No notifications';
  String get noNotificationsSubtitle =>
      'You don\'t have new notifications at the moment';
  String get filterNotifications => 'Filter notifications';
  String get notificationDeleted => 'Notification deleted';
  String get allNotifications => 'All notifications';
  String get academic => 'Academic';
  String get event => 'Event';
  String get alert => 'Alert';
  String get general => 'General';
  String get recentNotifications => 'Recent Notifications';

  // Attendance
  String get selectDate => 'Select Date';
  String get filterByStudent => 'Filter by Student';
  String get allStudents => 'All Students';
  String get noAttendanceData => 'No attendance data';
  String get noAttendanceDataSubtitle =>
      'There is no attendance data for the selected criteria';
  String get recentAttendance => 'Recent Attendance';
  String get noAttendanceRecords => 'No attendance records';
  String get attendanceToday => 'Today\'s Attendance';
  String get viewAttendance => 'View attendance of your children';
  String get calendar => 'Calendar';
  String get list => 'List';
  String get specialPermission => 'Special Permission';
  String get excellent => 'Excellent';
  String get good => 'Good';
  String get needsImprovement => 'Needs Improvement';

  // Attendance methods with parameters
  String attendanceRecordsCount(int count) => '$count attendance records';
  String noRecordsForDate(String date) => 'No records for $date';
  String attendanceForDate(String date) => 'Attendance for $date';
  String gradeLabel(String grade) => 'Grade $grade';
  String attendancePercentage(int percentage, String status) =>
      '$percentage% - $status';
  String fullDateFormat(int day, String month, int year) =>
      '$month $day, $year';

  // Month names
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  // Profile
  String get viewProfile => 'View your profile';
  String get about => 'About';
  String get version => 'Version';
  String get termsConditions => 'Terms & conditions';
  String get support => 'Support: contact & help';

  // Account Control
  String get security => 'Security';
  String get dangerZone => 'Danger Zone';
  String get dangerZoneDesc => 'Irreversible actions';
  String get changePassword => 'Change Password';
  String get changePasswordDesc => 'Update your account password';
  String get downloadData => 'Download Data';
  String get downloadDataDesc => 'Export your account data';
  String get clearCache => 'Clear Cache';
  String get clearCacheDesc => 'Clear app cache and temporary files';
  String get twoFactorAuth => 'Two-Factor Authentication';
  String get twoFactorAuthDesc => 'Enable 2FA for enhanced security';
  String get activeSessions => 'Active Sessions';
  String get activeSessionsDesc => 'View and manage active sessions';
  String get deleteAccount => 'Delete Account';
  String get deleteAccountDesc => 'Permanently delete your account';
  String get disableAccount => 'Disable Account';
  String get disableAccountWarning =>
      'This will temporarily disable your account';
  String get deleteAccountWarning => 'This action cannot be undone';
  String get disable => 'Disable';
  String get accountDisabled => 'Account temporarily disabled';
  String get accountDeletionStarted => 'Account deletion process started';
  String get navigatingToPasswordChange => 'Navigating to password change...';
  String get preparingDownload => 'Preparing download...';
  String get downloadReady => 'Download ready';
  String get clearingCache => 'Clearing cache...';
  String get cacheCleared => 'Cache cleared';
  String get twoFactorSetup => 'Setting up two-factor authentication...';
  String get viewingSessions => 'Viewing active sessions...';

  // Contact Information
  String get contactData => 'Contact Data';
  String get email => 'Email';
  String get primaryEmailAddress => 'Primary Email Address';
  String get notRegistered => 'Not Registered';
  String get securityInformation => 'Security Information';
  String get accountStatus => 'Account Status';
  String get verified => 'Verified';
  String get lastAccess => 'Last Access';
  String get todayAtTime => 'Today at Time';
  String get authentication => 'Authentication';
  String get enabled => 'Enabled';
  String get importantInformation => 'Important Information';
  String get contactAdminModifyInfo => 'Contact Admin to Modify Info';
  String get functionInDevelopment => 'Function in Development';
  String get contactAdmin => 'Contact Admin';
  String get contactInformation => 'Contact Information';
  String get viewContactData => 'Contact Data';

  // Family Information
  String get familyContactsRegistered => 'Family Contacts Registered';
  String get addNewContact => 'Add New Contact';
  String get familyInformation => 'Family Information';
  String get manageFamilyContacts => 'Manage Family Contacts';
  String get noFamilyContacts => 'No Family Contacts';
  String get addFamilyContactsEmergency => 'Add Family Contacts for Emergency';
  String get fullName => 'Full Name';
  String get nameRequired => 'Name Required';
  String get phone => 'Phone';
  String get phoneRequired => 'Phone Required';
  String get emailOptional => 'Email (Optional)';
  String get enterValidEmail => 'Enter Valid Email';
  String get enter => 'Enter';
  String get relationship => 'Relationship';
  String get clear => 'Clear';
  String get addContact => 'Add Contact';
  String get familyContactsUsedBySchool => 'Family Contacts Used by School';
  String get familyContactAddedSuccessfully =>
      'Family Contact Added Successfully';
  String get errorAddingContact => 'Error Adding Contact';
  String get editContactFeatureComingSoon => 'Edit Contact Feature Coming Soon';
  String get deleteContact => 'Delete Contact';
  String get confirmDeleteContact => 'Confirm Delete Contact';
  String get contactDeleted => 'Contact Deleted';

  // Notification Settings
  String get soundVibration => 'Sound & Vibration';
  String get notificationSettingsSubtitle => 'Notification Settings Subtitle';
  String get sound => 'Sound';
  String get soundSubtitle => 'Sound Subtitle';
  String get vibration => 'Vibration';
  String get vibrationSubtitle => 'Vibration Subtitle';
  String get testNotification => 'Test Notification';
  String get notificationTone => 'Notification Tone';
  String get notificationInfoTitle => 'Notification Info Title';
  String get notificationInfoText => 'Notification Info Text';
  String get soundDefault => 'Default';
  String get soundBell => 'Bell';
  String get soundChime => 'Chime';
  String get soundSoft => 'Soft';
  String get soundClassic => 'Classic';
  String get testNotificationWithSound => 'Test Notification with Sound';
  String get testNotificationWithoutSound => 'Test Notification without Sound';
  String get withVibration => 'with Vibration';

  // Personal Data
  String get personalData => 'Personal Data';
  String get personalInformation => 'Personal Information';
  String get firstName => 'First Name';
  String get firstNameRequired => 'First Name Required';
  String get lastName => 'Last Name';
  String get lastNameRequired => 'Last Name Required';
  String get emailRequired => 'Email Required';
  String get accountInformation => 'Account Information';
  String get userType => 'User Type';
  String get notSpecified => 'Not Specified';
  String get registrationDate => 'Registration Date';
  String get notAvailable => 'Not Available';
  String get associatedStudents => 'Associated Students';
  String get takePhoto => 'Take Photo';
  String get cameraFeatureComingSoon => 'Camera Feature Coming Soon';
  String get selectFromGallery => 'Select from Gallery';
  String get galleryFeatureComingSoon => 'Gallery Feature Coming Soon';
  String get deletePhoto => 'Delete Photo';
  String get photoDeleted => 'Photo Deleted';
  String get dataUpdatedSuccessfully => 'Data Updated Successfully';
  String get errorUpdatingData => 'Error Updating Data';

  // Personal Information View
  String get editInformation => 'Edit Information';
  String get editNameAndLastNames => 'Edit Name and Last Names';
  String get firstNameMinLength => 'First Name Min Length';
  String get lastNames => 'Last Names';
  String get lastNamesRequired => 'Last Names Required';
  String get lastNamesMinLength => 'Last Names Min Length';
  String get currentFullName => 'Current Full Name';
  String get reset => 'Reset';
  String get saveChanges => 'Save';
  String get formReset => 'Form Reset';
  String get personalInformationUpdatedSuccessfully =>
      'Personal Information Updated Successfully';
  String get errorUpdatingInformation => 'Error Updating Information';

  // Password Security
  String get securityTips => 'Security Tips';
  String get changePasswordSubtitle => 'Change Password Subtitle';
  String get currentPassword => 'Current Password';
  String get enterCurrentPassword => 'Enter Current Password';
  String get newPassword => 'New Password';
  String get enterNewPassword => 'Enter New Password';
  String get passwordMinLength => 'Password Min Length';
  String get confirmNewPassword => 'Confirm New Password';
  String get confirmPassword => 'Confirm Password';
  String get passwordsDoNotMatch => 'Passwords Do Not Match';
  String get securityTip1 => 'Security Tip 1';
  String get securityTip2 => 'Security Tip 2';
  String get securityTip3 => 'Security Tip 3';
  String get securityTip4 => 'Security Tip 4';
  String get passwordChangedSuccessfully => 'Password Changed Successfully';

  // Username Change
  String get newUsername => 'New Username';
  String get changeUsername => 'Change Username';
  String get modifyYourUniqueUsername => 'Modify Your Unique Username';
  String get currentUser => 'Current User';
  String get newUsernameLabel => 'New Username Label';
  String get usernameRequired => 'Username Required';
  String get usernameMinLength => 'Username Min Length';
  String get usernameInvalidCharacters => 'Username Invalid Characters';
  String get confirmYourPassword => 'Confirm Your Password';
  String get passwordRequiredForConfirmation =>
      'Password Required for Confirmation';
  String get usernameRequirements => 'Username Requirements';
  String get minimumCharacters => 'Minimum Characters';
  String get onlyLettersNumbersUnderscores =>
      'Only Letters Numbers Underscores';
  String get mustBeUniqueInSystem => 'Must Be Unique in System';
  String get changeUser => 'Change User';
  String get important => 'Important';
  String get usernameChangeWarning => 'Username Change Warning';
  String get usernameNotAvailable => 'Username Not Available';
  String get usernameChangedSuccessfully => 'Username Changed Successfully';
  String get errorChangingUsername => 'Error Changing Username';

  // Profile
  String get myProfile => 'My Profile';
  String get manageYourAccount => 'Manage Your Account';
  String get user => 'User';
  String get parentRole => 'Parent Role';
  String get activeDays => 'Active Days';
  String get account => 'Account';
  String get editProfileAndContactData => 'Edit Profile and Contact Data';
  String get changePasswordAndAuthentication =>
      'Change Password and Authentication';
  String get emergencyDataAndContacts => 'Emergency Data and Contacts';
  String get preferences => 'Preferences';
  String get configureAlertsAndReminders => 'Configure Alerts and Reminders';
  String get helpCenter => 'Help Center';
  String get faqAndGuides => 'FAQ and Guides';
  String get sendFeedback => 'Send Feedback';
  String get shareYourExperienceWithUs => 'Share Your Experience with Us';
  String get versionTermsAndPrivacy => 'Version Terms and Privacy';
  String get signOut => 'Sign Out';
  String get theme => 'Theme';
  String get lightMode => 'Light Mode';
  String get securitySettings => 'Security Settings';
  String get securityOptionsComingSoon => 'Security Options Coming Soon';
  String get understood => 'Understood';
  String get familyInfoManagementComingSoon =>
      'Family Info Management Coming Soon';
  String get selectLanguage => 'Select Language';
  String get helpCenterAndDocumentationComingSoon =>
      'Help Center and Documentation Coming Soon';
  String get feedbackSystemComingSoon => 'Feedback System Coming Soon';
  String get aboutAlertaEscolar => 'About Alerta Escolar';
  String get aboutDescription => 'About Description';
  String get confirmSignOut => 'Confirm Sign Out';

  // Reports
  String get reportsAndStatistics => 'Reports and Statistics';
  String get summary => 'Summary';
  String get activity => 'Activity';
  String get student => 'Student';
  String get period => 'Period';
  String get selectPeriod => 'Select Period';
  String get generalSummary => 'General Summary';
  String get lastMonth => 'Last Month';
  String get punctuality => 'Punctuality';
  String get thisWeek => 'This Week';
  String get events => 'Events';
  String get upcoming => 'Upcoming';
  String get attendanceTrend => 'Attendance Trend';
  String get trendChartComingSoon => 'Trend Chart Coming Soon';
  String get noStudentsForAttendanceReport =>
      'No Students for Attendance Report';
  String get attendanceReport => 'Attendance Report';
  String get noActivity => 'No Activity';
  String get noNotificationsInSelectedPeriod =>
      'No Notifications in Selected Period';
  String get activityReport => 'Activity Report';
  String get summaryByType => 'Summary by Type';
  String get recentActivity => 'Recent Activity';
  String get entries => 'Entries';
  String get exits => 'Exits';
  String get delays => 'Delays';
  String get absences => 'Absences';
  String get permissions => 'Permissions';
  String get alerts => 'Alerts';
  String get announcements => 'Announcements';
  String get yesterday => 'Yesterday';

  // Students
  String get myStudents => 'My Students';
  String get registeredStudents => 'Registered Students';
  String get noStudentsLinked => 'No Students Linked';
  String get loadingStudents => 'Loading Students';
  String get errorLoadingStudents => 'Error Loading Students';
  String get retry => 'Retry';
  String get noStudentsRegistered => 'No Students Registered';
  String get addFirstStudentInstructions => 'Add First Student Instructions';
  String get active => 'Active';
  String get inactive => 'Inactive';

  // Add Student
  String get instructions => 'Instructions';
  String get linkStudentInstructions => 'Link Student Instructions';
  String get scanQRCode => 'Scan QR Code';
  String get useCameraToScanQR => 'Use Camera to Scan QR';
  String get or => 'Or';
  String get manualEntry => 'Manual Entry';
  String get enterStudentKeyCode => 'Enter Student Key Code';
  String get keyCode => 'Key Code';
  String get keyCodeExample => 'Key Code Example';
  String get pleaseEnterKeyCode => 'Please Enter Key Code';
  String get keyCodeMinLength => 'Key Code Min Length';
  String get linking => 'Linking';
  String get linkStudent => 'Link Student';
  String get qrScanFunctionalityComingSoon =>
      'QR Scan Functionality Coming Soon';
  String get toConfirm => 'To Confirm';
  String get studentLinkedSuccessfully => 'Student Linked Successfully';
  String get errorLinkingStudent => 'Error Linking Student';

  // Student Detail
  String get viewSchedule => 'View Schedule';
  String get details => 'Details';
  String get academicInformation => 'Academic Information';
  String get gradeLevel => 'Grade Level';
  String get studentId => 'Student ID';
  String get noId => 'No ID';
  String get keyInformation => 'Key Information';
  String get notAssigned => 'Not Assigned';
  String get linkDate => 'Link Date';
  String get downloadDigitalCredential => 'Download Digital Credential';
  String get editFunctionalityComingSoon => 'Edit Functionality Coming Soon';
  String get deleteStudent => 'Delete Student';
  String get studentDeletedSuccessfully => 'Student Deleted Successfully';

  // Schedule
  String get errorLoadingSchedule => 'Error Loading Schedule';
  String get classSchedule => 'Class Schedule';
  String get monday => 'Monday';
  String get tuesday => 'Tuesday';
  String get wednesday => 'Wednesday';
  String get thursday => 'Thursday';
  String get friday => 'Friday';
  String get saturday => 'Saturday';
  String get sunday => 'Sunday';
  String get loadingSchedule => 'Loading Schedule';
  String get noScheduledClasses => 'No Scheduled Classes';

  // Methods with parameters
  String studentsCount(int count) => '$count students';
  String studentsLinked(int count) => '$count students linked';
  String generatingCredentialFor(String name) =>
      'Generating credential for $name';
  String deleteStudentConfirmation(String name) => 'Delete student $name?';
  String noClassesScheduledForDay(String day) =>
      'No classes scheduled for $day';
  String daysAgo(int days) => '$days days ago';

  // Missing keys for app settings
  String get syncData => 'Sync Data';
  String get autoSync => 'Auto Sync';
  String get autoSyncDescription => 'Automatically sync data when connected';
  String get offlineMode => 'Offline Mode';
  String get offlineModeDescription =>
      'Work offline when no connection available';
  String get privacyAnalytics => 'Privacy & Analytics';
  String get analyticsEnabled => 'Analytics Enabled';
  String get analyticsDescription =>
      'Help improve the app by sharing usage data';
  String get crashReporting => 'Crash Reporting';
  String get crashReportingDescription =>
      'Send crash reports to help fix issues';
  String get storageCache => 'Storage & Cache';
  String get cacheSize => 'Cache Size';
  String get clearCacheDescription => 'Clear app cache and temporary files';
  String get downloadQuality => 'Download Quality';
  String get appUpdates => 'App Updates';
  String get autoUpdate => 'Auto Update';
  String get autoUpdateDescription => 'Automatically download app updates';
  String get betaFeatures => 'Beta Features';
  String get betaFeaturesDescription => 'Enable experimental features';
  String get appSettings => 'App Settings';
  String get appConfiguration => 'App Configuration';
  String get low => 'Low';
  String get medium => 'Medium';
  String get high => 'High';
  String get cacheClearError => 'Error clearing cache';

  // Missing keys for theme selection
  String get themeSelection => 'Theme Selection';
  String get chooseYourPreferredTheme => 'Choose your preferred theme';
  String get lightModeDescription => 'Light and clean interface';
  String get darkModeDescription => 'Dark interface for low light';
  String get systemTheme => 'System Theme';
  String get systemThemeDescription => 'Follow system theme settings';

  // Missing keys for language selection
  String get choosePreferredLanguage => 'Choose your preferred language';

  // Missing keys for personal data navigation
  String get managePersonalDetails => 'Manage your personal details';
  String get manageAccountData => 'Manage your account data';
  String get passwordSecurity => 'Password & Security';
  String get parentAccount => 'Parent Account';
  String get administrator => 'Administrator';
  String get teacher => 'Teacher';
  String get parent => 'Parent';
  String get lastLogin => 'Last Login';

  // Missing keys for home view
  String get welcomeBack => 'Welcome back';
  String get newNotifications => 'new';
  String get entryRegistered => 'Entry registered';
  String get exitRegistered => 'Exit registered';
  String get arrivedLate => 'Arrived late';
  String get announcement => 'Announcement';
  String get tapToViewDetails => 'Tap to view details';
  String get statistics => 'Statistics';
  String get sevenDays => '7 days';
  String get oneMonth => '1 month';
  String get weeklyAttendance => 'Weekly attendance';
  String get monthlyAttendance => 'Monthly attendance';
  String get plusFivePercent => '+5% vs previous';
  String get plusTwoPercent => '+2% vs previous';
  String get attendances => 'Attendances';
  String get lateArrivals => 'Late arrivals';
  String get todaysSchedule => 'Today\'s schedule';
  String get morningClasses => 'Morning classes';
  String get afternoonClasses => 'Afternoon classes';
  String get extracurricularActivities => 'Extracurricular activities';
  String get mathSpanishSciences => 'Math, Spanish, Sciences';
  String get historyPhysicalEducation => 'History, Physical Education';
  String get chessClub => 'Chess club';
  String get inProgress => 'In progress';
  String get quickActions => 'Quick actions';
  String get viewHistory => 'View history';
  String get notificationsWillAppearHere => 'Notifications will appear here';
  String get addStudentToStart => 'Add a student to start';

  // Missing keys for notifications view
  String get categories => 'Categories';
  String get accessAlerts => 'Access Alerts';
  String get fourteenDays => '14 days';
  String get accessRecordsAndAlerts => 'access records and alerts';

  // Schedule view additional keys
  String get weeklySchedule => 'Weekly Schedule';
  String get selectStudent => 'Select Student';

  // Family relationship types
  String get father => 'Father';
  String get mother => 'Mother';
  String get grandfather => 'Grandfather';
  String get grandmother => 'Grandmother';
  String get guardian => 'Guardian';
  String get guardianFemale => 'Guardian (Female)';
  String get uncle => 'Uncle';
  String get aunt => 'Aunt';
  String get brother => 'Brother';
  String get sister => 'Sister';
  String get otherFamily => 'Other Family';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue on GitHub with a '
      'reproducible sample app and the gen-l10n configuration that was used.');
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'School Alert';

  @override
  String get homeTitle => 'Dashboard';

  @override
  String get attendance => 'Attendance';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get students => 'Students';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get welcome => 'Welcome';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get viewAll => 'View All';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get today => 'Today';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get undo => 'Undo';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get grade => 'Grade';

  @override
  String get noData => 'No data';

  @override
  String get addStudent => 'Add Student';

  @override
  String get studentName => 'Student Name';

  @override
  String get studentGrade => 'Grade';

  @override
  String get noStudentsTitle => 'No students registered';

  @override
  String get noStudentsMessage =>
      'Register your children to start monitoring their school activity';

  @override
  String get noStudents => 'No Students';

  @override
  String get addFirstStudent => 'Add your first student';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'You don\'t have new notifications at the moment';

  @override
  String get filterNotifications => 'Filter notifications';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get allNotifications => 'All notifications';

  @override
  String get academic => 'Academic';

  @override
  String get event => 'Event';

  @override
  String get alert => 'Alert';

  @override
  String get general => 'General';

  @override
  String get recentNotifications => 'Recent Notifications';

  @override
  String get selectDate => 'Select Date';

  @override
  String get filterByStudent => 'Filter by Student';

  @override
  String get allStudents => 'All Students';

  @override
  String get noAttendanceData => 'No attendance data';

  @override
  String get noAttendanceDataSubtitle =>
      'There is no attendance data for the selected criteria';

  @override
  String get recentAttendance => 'Recent Attendance';

  @override
  String get noAttendanceRecords => 'No attendance records';

  @override
  String get attendanceToday => 'Today\'s Attendance';

  @override
  String get viewAttendance => 'View attendance of your children';

  @override
  String get calendar => 'Calendar';

  @override
  String get list => 'List';

  @override
  String get specialPermission => 'Special Permission';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get needsImprovement => 'Needs Improvement';

  @override
  String attendanceRecordsCount(int count) => '$count attendance records';

  @override
  String noRecordsForDate(String date) => 'No records for $date';

  @override
  String attendanceForDate(String date) => 'Attendance for $date';

  @override
  String gradeLabel(String grade) => 'Grade $grade';

  @override
  String attendancePercentage(int percentage, String status) =>
      '$percentage% - $status';

  @override
  String fullDateFormat(int day, String month, int year) =>
      '$month $day, $year';

  @override
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  @override
  String get viewProfile => 'View your profile';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get termsConditions => 'Terms & conditions';

  @override
  String get support => 'Support: contact & help';

  // Account Control - English
  @override
  String get security => 'Security';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get dangerZoneDesc => 'Irreversible actions';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordDesc => 'Update your account password';

  @override
  String get downloadData => 'Download Data';

  @override
  String get downloadDataDesc => 'Export your account data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheDesc => 'Clear app cache and temporary files';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get twoFactorAuthDesc => 'Enable 2FA for enhanced security';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get activeSessionsDesc => 'View and manage active sessions';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDesc => 'Permanently delete your account';

  @override
  String get disableAccount => 'Disable Account';

  @override
  String get disableAccountWarning =>
      'This will temporarily disable your account';

  @override
  String get deleteAccountWarning => 'This action cannot be undone';

  @override
  String get disable => 'Disable';

  @override
  String get accountDisabled => 'Account temporarily disabled';

  @override
  String get accountDeletionStarted => 'Account deletion process started';

  @override
  String get navigatingToPasswordChange => 'Navigating to password change...';

  @override
  String get preparingDownload => 'Preparing download...';

  @override
  String get downloadReady => 'Download ready';

  @override
  String get clearingCache => 'Clearing cache...';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get twoFactorSetup => 'Setting up two-factor authentication...';

  @override
  String get viewingSessions => 'Viewing active sessions...';

  // Contact Information - English
  @override
  String get contactData => 'Contact Data';

  @override
  String get email => 'Email';

  @override
  String get primaryEmailAddress => 'Primary Email Address';

  @override
  String get notRegistered => 'Not Registered';

  @override
  String get securityInformation => 'Security Information';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get verified => 'Verified';

  @override
  String get lastAccess => 'Last Access';

  @override
  String get todayAtTime => 'Today at Time';

  @override
  String get authentication => 'Authentication';

  @override
  String get enabled => 'Enabled';

  @override
  String get importantInformation => 'Important Information';

  @override
  String get contactAdminModifyInfo =>
      'Contact administrator to modify information';

  @override
  String get functionInDevelopment => 'Function in development';

  @override
  String get contactAdmin => 'Contact Admin';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get viewContactData => 'Contact data';

  // Family Information - English
  @override
  String get familyContactsRegistered => 'Family contacts registered';

  @override
  String get addNewContact => 'Add new contact';

  @override
  String get familyInformation => 'Family Information';

  @override
  String get manageFamilyContacts => 'Manage family contacts';

  @override
  String get noFamilyContacts => 'No family contacts';

  @override
  String get addFamilyContactsEmergency =>
      'Add family contacts for emergencies';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phone => 'Phone';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get emailOptional => 'Email (Optional)';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enter => 'Enter';

  @override
  String get relationship => 'Relationship';

  @override
  String get clear => 'Clear';

  @override
  String get addContact => 'Add Contact';

  @override
  String get familyContactsUsedBySchool =>
      'Family contacts are used by the school for emergencies';

  @override
  String get familyContactAddedSuccessfully =>
      'Family contact added successfully';

  @override
  String get errorAddingContact => 'Error adding contact';

  @override
  String get editContactFeatureComingSoon => 'Edit contact feature coming soon';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String get confirmDeleteContact =>
      'Are you sure you want to delete this contact?';

  @override
  String get contactDeleted => 'Contact deleted successfully';

  // Notification Settings - English
  @override
  String get soundVibration => 'Sound & Vibration';

  @override
  String get notificationSettingsSubtitle =>
      'Configure notification preferences';

  @override
  String get sound => 'Sound';

  @override
  String get soundSubtitle => 'Notification sound settings';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Vibration settings';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get notificationTone => 'Notification Tone';

  @override
  String get notificationInfoTitle => 'Notification Information';

  @override
  String get notificationInfoText => 'Configure how you receive notifications';

  @override
  String get soundDefault => 'Default';

  @override
  String get soundBell => 'Bell';

  @override
  String get soundChime => 'Chime';

  @override
  String get soundSoft => 'Soft';

  @override
  String get soundClassic => 'Classic';

  @override
  String get testNotificationWithSound => 'Test notification with sound';

  @override
  String get testNotificationWithoutSound => 'Test notification without sound';

  @override
  String get withVibration => 'with vibration';

  // Personal Data - English
  @override
  String get personalData => 'Personal Data';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get userType => 'User Type';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get notAvailable => 'Not available';

  @override
  String get associatedStudents => 'Associated Students';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get cameraFeatureComingSoon => 'Camera feature coming soon';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get galleryFeatureComingSoon => 'Gallery feature coming soon';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get photoDeleted => 'Photo deleted successfully';

  @override
  String get dataUpdatedSuccessfully => 'Data updated successfully';

  @override
  String get errorUpdatingData => 'Error updating data';

  // Personal Information View - English
  @override
  String get editInformation => 'Edit Information';

  @override
  String get editNameAndLastNames => 'Edit name and last names';

  @override
  String get firstNameMinLength => 'First name must be at least 2 characters';

  @override
  String get lastNames => 'Last Names';

  @override
  String get lastNamesRequired => 'Last names are required';

  @override
  String get lastNamesMinLength => 'Last names must be at least 2 characters';

  @override
  String get currentFullName => 'Current full name';

  @override
  String get reset => 'Reset';

  @override
  String get saveChanges => 'Save';

  @override
  String get formReset => 'Form has been reset';

  @override
  String get personalInformationUpdatedSuccessfully =>
      'Personal information updated successfully';

  @override
  String get errorUpdatingInformation => 'Error updating information';

  // Password Security - English
  @override
  String get securityTips => 'Security Tips';

  @override
  String get changePasswordSubtitle => 'Change your account password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get securityTip1 => 'Use at least 8 characters';

  @override
  String get securityTip2 => 'Include uppercase and lowercase letters';

  @override
  String get securityTip3 => 'Add numbers and special characters';

  @override
  String get securityTip4 => 'Don\'t use personal information';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  // Username Change - English
  @override
  String get newUsername => 'New Username';

  @override
  String get changeUsername => 'Change Username';

  @override
  String get modifyYourUniqueUsername => 'Modify your unique username';

  @override
  String get currentUser => 'Current User';

  @override
  String get newUsernameLabel => 'New Username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get usernameInvalidCharacters =>
      'Username can only contain letters, numbers, and underscores';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordRequiredForConfirmation =>
      'Password is required for confirmation';

  @override
  String get usernameRequirements => 'Username Requirements';

  @override
  String get minimumCharacters => '3 minimum characters';

  @override
  String get onlyLettersNumbersUnderscores =>
      'Only letters, numbers, and underscores';

  @override
  String get mustBeUniqueInSystem => 'Must be unique in the system';

  @override
  String get changeUser => 'Change User';

  @override
  String get important => 'Important';

  @override
  String get usernameChangeWarning =>
      'Changing your username may affect your login';

  @override
  String get usernameNotAvailable => 'Username not available';

  @override
  String get usernameChangedSuccessfully => 'Username changed successfully';

  @override
  String get errorChangingUsername => 'Error changing username';

  // Profile - English
  @override
  String get myProfile => 'My Profile';

  @override
  String get manageYourAccount => 'Manage your account';

  @override
  String get user => 'User';

  @override
  String get parentRole => 'Parent/Guardian';

  @override
  String get activeDays => 'Active days';

  @override
  String get account => 'Account';

  @override
  String get editProfileAndContactData => 'Edit profile and contact data';

  @override
  String get changePasswordAndAuthentication =>
      'Change password and authentication';

  @override
  String get emergencyDataAndContacts => 'Emergency data and contacts';

  @override
  String get preferences => 'Preferences';

  @override
  String get configureAlertsAndReminders => 'Configure alerts and reminders';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get faqAndGuides => 'FAQ and guides';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get shareYourExperienceWithUs => 'Share your experience with us';

  @override
  String get versionTermsAndPrivacy => 'Version, terms and privacy';

  @override
  String get signOut => 'Sign Out';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get securityOptionsComingSoon => 'Security options coming soon';

  @override
  String get understood => 'Understood';

  @override
  String get familyInfoManagementComingSoon =>
      'Family information management coming soon';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get helpCenterAndDocumentationComingSoon =>
      'Help center and documentation coming soon';

  @override
  String get feedbackSystemComingSoon => 'Feedback system coming soon';

  @override
  String get aboutAlertaEscolar => 'About School Alert';

  @override
  String get aboutDescription =>
      'School Alert is an application designed to keep parents informed about their children\'s school activities.';

  @override
  String get confirmSignOut => 'Are you sure you want to sign out?';

  // Reports - English
  @override
  String get reportsAndStatistics => 'Reports & Statistics';

  @override
  String get summary => 'Summary';

  @override
  String get activity => 'Activity';

  @override
  String get student => 'Student';

  @override
  String get period => 'Period';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get generalSummary => 'General Summary';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get punctuality => 'Punctuality';

  @override
  String get thisWeek => 'This Week';

  @override
  String get events => 'Events';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get attendanceTrend => 'Attendance Trend';

  @override
  String get trendChartComingSoon => 'Trend chart coming soon';

  @override
  String get noStudentsForAttendanceReport =>
      'No students available for attendance report';

  @override
  String get attendanceReport => 'Attendance Report';

  @override
  String get noActivity => 'No Activity';

  @override
  String get noNotificationsInSelectedPeriod =>
      'No notifications in the selected period';

  @override
  String get activityReport => 'Activity Report';

  @override
  String get summaryByType => 'Summary by Type';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get entries => 'Entries';

  @override
  String get exits => 'Exits';

  @override
  String get delays => 'Delays';

  @override
  String get absences => 'Absences';

  @override
  String get permissions => 'Permissions';

  @override
  String get alerts => 'Alerts';

  @override
  String get announcements => 'Announcements';

  @override
  String get yesterday => 'Yesterday';

  // Students - English
  @override
  String get myStudents => 'My Students';

  @override
  String get registeredStudents => 'Registered Students';

  @override
  String get noStudentsLinked => 'No students linked';

  @override
  String get loadingStudents => 'Loading students...';

  @override
  String get errorLoadingStudents => 'Error loading students';

  @override
  String get retry => 'Retry';

  @override
  String get noStudentsRegistered => 'No students registered';

  @override
  String get addFirstStudentInstructions =>
      'Add your first student to start monitoring their school activity';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  // Add Student - English
  @override
  String get instructions => 'Instructions';

  @override
  String get linkStudentInstructions =>
      'Link a student using their QR code or key code provided by the school';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get useCameraToScanQR => 'Use camera to scan QR code';

  @override
  String get or => 'Or';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get enterStudentKeyCode => 'Enter student key code manually';

  @override
  String get keyCode => 'Key Code';

  @override
  String get keyCodeExample => 'e.g., STU123456';

  @override
  String get pleaseEnterKeyCode => 'Please enter the key code';

  @override
  String get keyCodeMinLength => 'Key code must be at least 6 characters';

  @override
  String get linking => 'Linking';

  @override
  String get linkStudent => 'Link Student';

  @override
  String get qrScanFunctionalityComingSoon =>
      'QR scan functionality coming soon';

  @override
  String get toConfirm => 'to confirm';

  @override
  String get studentLinkedSuccessfully => 'Student linked successfully';

  @override
  String get errorLinkingStudent => 'Error linking student';

  // Student Detail - English
  @override
  String get viewSchedule => 'View Schedule';

  @override
  String get details => 'Details';

  @override
  String get academicInformation => 'Academic Information';

  @override
  String get gradeLevel => 'Grade Level';

  @override
  String get studentId => 'Student ID';

  @override
  String get noId => 'No ID';

  @override
  String get keyInformation => 'Key Information';

  @override
  String get notAssigned => 'Not assigned';

  @override
  String get linkDate => 'Link Date';

  @override
  String get downloadDigitalCredential => 'Download Digital Credential';

  @override
  String get editFunctionalityComingSoon => 'Edit functionality coming soon';

  @override
  String get deleteStudent => 'Delete Student';

  @override
  String get studentDeletedSuccessfully => 'Student deleted successfully';

  // Schedule - English
  @override
  String get errorLoadingSchedule => 'Error loading schedule';

  @override
  String get classSchedule => 'Class Schedule';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get loadingSchedule => 'Loading schedule...';

  @override
  String get noScheduledClasses => 'No scheduled classes';

  // Methods with parameters - English
  @override
  String studentsCount(int count) => '$count students';

  @override
  String studentsLinked(int count) => '$count students linked';

  @override
  String generatingCredentialFor(String name) =>
      'Generating credential for $name';

  @override
  String deleteStudentConfirmation(String name) =>
      'Are you sure you want to delete $name?';

  @override
  String noClassesScheduledForDay(String day) =>
      'No classes scheduled for $day';

  @override
  String daysAgo(int days) => '$days days ago';

  // Missing keys for app settings - English
  @override
  String get syncData => 'Sync Data';

  @override
  String get autoSync => 'Auto Sync';

  @override
  String get autoSyncDescription => 'Automatically sync data when connected';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get offlineModeDescription =>
      'Work offline when no connection available';

  @override
  String get privacyAnalytics => 'Privacy & Analytics';

  @override
  String get analyticsEnabled => 'Analytics Enabled';

  @override
  String get analyticsDescription =>
      'Help improve the app by sharing usage data';

  @override
  String get crashReporting => 'Crash Reporting';

  @override
  String get crashReportingDescription =>
      'Send crash reports to help fix issues';

  @override
  String get storageCache => 'Storage & Cache';

  @override
  String get cacheSize => 'Cache Size';

  @override
  String get clearCacheDescription => 'Clear app cache and temporary files';

  @override
  String get downloadQuality => 'Download Quality';

  @override
  String get appUpdates => 'App Updates';

  @override
  String get autoUpdate => 'Auto Update';

  @override
  String get autoUpdateDescription => 'Automatically download app updates';

  @override
  String get betaFeatures => 'Beta Features';

  @override
  String get betaFeaturesDescription => 'Enable experimental features';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appConfiguration => 'App Configuration';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get cacheClearError => 'Error clearing cache';

  // Missing keys for theme selection - English
  @override
  String get themeSelection => 'Theme Selection';

  @override
  String get chooseYourPreferredTheme => 'Choose your preferred theme';

  @override
  String get lightModeDescription => 'Light and clean interface';

  @override
  String get darkModeDescription => 'Dark interface for low light';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get systemThemeDescription => 'Follow system theme settings';

  // Missing keys for language selection - English
  @override
  String get choosePreferredLanguage => 'Choose your preferred language';

  // Missing keys for personal data navigation - English
  @override
  String get managePersonalDetails => 'Manage your personal details';

  @override
  String get manageAccountData => 'Manage your account data';

  @override
  String get passwordSecurity => 'Password & Security';

  @override
  String get parentAccount => 'Parent Account';

  @override
  String get administrator => 'Administrator';

  @override
  String get teacher => 'Teacher';

  @override
  String get parent => 'Parent';

  @override
  String get lastLogin => 'Last Login';

  // Missing keys for home view - English
  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get newNotifications => 'new';

  @override
  String get entryRegistered => 'Entry registered';

  @override
  String get exitRegistered => 'Exit registered';

  @override
  String get arrivedLate => 'Arrived late';

  @override
  String get announcement => 'Announcement';

  @override
  String get tapToViewDetails => 'Tap to view details';

  @override
  String get statistics => 'Statistics';

  @override
  String get sevenDays => '7 days';

  @override
  String get oneMonth => '1 month';

  @override
  String get weeklyAttendance => 'Weekly attendance';

  @override
  String get monthlyAttendance => 'Monthly attendance';

  @override
  String get plusFivePercent => '+5% vs previous';

  @override
  String get plusTwoPercent => '+2% vs previous';

  @override
  String get attendances => 'Attendances';

  @override
  String get lateArrivals => 'Late arrivals';

  @override
  String get todaysSchedule => 'Today\'s schedule';

  @override
  String get morningClasses => 'Morning classes';

  @override
  String get afternoonClasses => 'Afternoon classes';

  @override
  String get extracurricularActivities => 'Extracurricular activities';

  @override
  String get mathSpanishSciences => 'Math, Spanish, Sciences';

  @override
  String get historyPhysicalEducation => 'History, Physical Education';

  @override
  String get chessClub => 'Chess club';

  @override
  String get inProgress => 'In progress';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get viewHistory => 'View history';

  @override
  String get notificationsWillAppearHere => 'Notifications will appear here';

  @override
  String get addStudentToStart => 'Add a student to start';

  // Missing keys for notifications view - English
  @override
  String get categories => 'Categories';

  @override
  String get accessAlerts => 'Access Alerts';

  @override
  String get fourteenDays => '14 days';

  @override
  String get accessRecordsAndAlerts => 'access records and alerts';

  // Schedule view additional keys - English
  @override
  String get weeklySchedule => 'Weekly Schedule';

  // Student selection - English
  @override
  String get selectStudent => 'Select Student';

  // Family relationship types - English
  @override
  String get father => 'Father';

  @override
  String get mother => 'Mother';

  @override
  String get grandfather => 'Grandfather';

  @override
  String get grandmother => 'Grandmother';

  @override
  String get guardian => 'Guardian';

  @override
  String get guardianFemale => 'Guardian';

  @override
  String get uncle => 'Uncle';

  @override
  String get aunt => 'Aunt';

  @override
  String get brother => 'Brother';

  @override
  String get sister => 'Sister';

  @override
  String get otherFamily => 'Other Family';
}

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs() : super('es');

  @override
  String get appTitle => 'Alerta Escolar';

  @override
  String get homeTitle => 'Panel';

  @override
  String get attendance => 'Asistencia';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get profile => 'Perfil';

  @override
  String get students => 'Estudiantes';

  @override
  String get settings => 'Configuración';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get viewAll => 'Ver Todas';

  @override
  String get present => 'Presente';

  @override
  String get absent => 'Ausente';

  @override
  String get late => 'Tarde';

  @override
  String get today => 'Hoy';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get undo => 'Deshacer';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String get grade => 'Grado';

  @override
  String get noData => 'Sin datos';

  @override
  String get addStudent => 'Agregar Estudiante';

  @override
  String get studentName => 'Nombre del Estudiante';

  @override
  String get studentGrade => 'Grado';

  @override
  String get noStudentsTitle => 'Sin estudiantes registrados';

  @override
  String get noStudentsMessage =>
      'Registra a tus hijos para comenzar a monitorear su actividad escolar';

  @override
  String get noStudents => 'Sin Estudiantes';

  @override
  String get addFirstStudent => 'Agrega tu primer estudiante';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get noNotificationsSubtitle =>
      'No tienes notificaciones nuevas en este momento';

  @override
  String get filterNotifications => 'Filtrar notificaciones';

  @override
  String get notificationDeleted => 'Notificación eliminada';

  @override
  String get allNotifications => 'Todas las notificaciones';

  @override
  String get academic => 'Académico';

  @override
  String get event => 'Evento';

  @override
  String get alert => 'Alerta';

  @override
  String get general => 'General';

  @override
  String get recentNotifications => 'Notificaciones Recientes';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get filterByStudent => 'Filtrar por Estudiante';

  @override
  String get allStudents => 'Todos los Estudiantes';

  @override
  String get noAttendanceData => 'Sin datos de asistencia';

  @override
  String get noAttendanceDataSubtitle =>
      'No hay datos de asistencia para los criterios seleccionados';

  @override
  String get recentAttendance => 'Asistencia Reciente';

  @override
  String get noAttendanceRecords => 'Sin registros de asistencia';

  @override
  String get attendanceToday => 'Asistencia de Hoy';

  @override
  String get viewAttendance => 'Ver asistencia de tus hijos';

  @override
  String get calendar => 'Calendario';

  @override
  String get list => 'Lista';

  @override
  String get specialPermission => 'Permiso Especial';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Bueno';

  @override
  String get needsImprovement => 'Necesita Mejorar';

  @override
  String attendanceRecordsCount(int count) => '$count registros de asistencia';

  @override
  String noRecordsForDate(String date) => 'Sin registros para $date';

  @override
  String attendanceForDate(String date) => 'Asistencia para $date';

  @override
  String gradeLabel(String grade) => 'Grado $grade';

  @override
  String attendancePercentage(int percentage, String status) =>
      '$percentage% - $status';

  @override
  String fullDateFormat(int day, String month, int year) =>
      '$day de $month de $year';

  @override
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'enero';
      case 2:
        return 'febrero';
      case 3:
        return 'marzo';
      case 4:
        return 'abril';
      case 5:
        return 'mayo';
      case 6:
        return 'junio';
      case 7:
        return 'julio';
      case 8:
        return 'agosto';
      case 9:
        return 'septiembre';
      case 10:
        return 'octubre';
      case 11:
        return 'noviembre';
      case 12:
        return 'diciembre';
      default:
        return 'Desconocido';
    }
  }

  @override
  String get viewProfile => 'Ver tu perfil';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get termsConditions => 'Términos y condiciones';

  @override
  String get support => 'Soporte: contacto y ayuda';

  // Account Control - Spanish
  @override
  String get security => 'Seguridad';

  @override
  String get dangerZone => 'Zona Peligrosa';

  @override
  String get dangerZoneDesc => 'Acciones irreversibles';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get changePasswordDesc => 'Actualiza la contraseña de tu cuenta';

  @override
  String get downloadData => 'Descargar Datos';

  @override
  String get downloadDataDesc => 'Exportar los datos de tu cuenta';

  @override
  String get clearCache => 'Limpiar Caché';

  @override
  String get clearCacheDesc => 'Limpiar caché y archivos temporales de la app';

  @override
  String get twoFactorAuth => 'Autenticación de Dos Factores';

  @override
  String get twoFactorAuthDesc => 'Habilitar 2FA para mayor seguridad';

  @override
  String get activeSessions => 'Sesiones Activas';

  @override
  String get activeSessionsDesc => 'Ver y gestionar sesiones activas';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountDesc => 'Eliminar permanentemente tu cuenta';

  @override
  String get disableAccount => 'Deshabilitar Cuenta';

  @override
  String get disableAccountWarning =>
      'Esto deshabilitará temporalmente tu cuenta';

  @override
  String get deleteAccountWarning => 'Esta acción no se puede deshacer';

  @override
  String get disable => 'Deshabilitar';

  @override
  String get accountDisabled => 'Cuenta temporalmente deshabilitada';

  @override
  String get accountDeletionStarted =>
      'Proceso de eliminación de cuenta iniciado';

  @override
  String get navigatingToPasswordChange =>
      'Navegando al cambio de contraseña...';

  @override
  String get preparingDownload => 'Preparando descarga...';

  @override
  String get downloadReady => 'Descarga lista';

  @override
  String get clearingCache => 'Limpiando caché...';

  @override
  String get cacheCleared => 'Caché limpiado';

  @override
  String get twoFactorSetup => 'Configurando autenticación de dos factores...';

  @override
  String get viewingSessions => 'Viendo sesiones activas...';

  // Contact Information - Spanish
  @override
  String get contactData => 'Datos de Contacto';

  @override
  String get email => 'E-Mail';

  @override
  String get primaryEmailAddress => 'Dirección de Correo Principal';

  @override
  String get notRegistered => 'No Registrado';

  @override
  String get securityInformation => 'Información de Seguridad';

  @override
  String get accountStatus => 'Estado de Cuenta';

  @override
  String get verified => 'Verificado';

  @override
  String get lastAccess => 'Último Acceso';

  @override
  String get todayAtTime => 'Hoy a las';

  @override
  String get authentication => 'Autenticación';

  @override
  String get enabled => 'Habilitado';

  @override
  String get importantInformation => 'Información Importante';

  @override
  String get contactAdminModifyInfo =>
      'Contacte al administrador para modificar información';

  @override
  String get functionInDevelopment => 'Función en desarrollo';

  @override
  String get contactAdmin => 'Contactar Administrador';

  @override
  String get contactInformation => 'Información de Contacto';

  @override
  String get viewContactData => 'Datos de contacto';

  // Family Information - Spanish
  @override
  String get familyContactsRegistered => 'Contactos familiares registrados';

  @override
  String get addNewContact => 'Agregar nuevo contacto';

  @override
  String get familyInformation => 'Información Familiar';

  @override
  String get manageFamilyContacts => 'Gestionar contactos familiares';

  @override
  String get noFamilyContacts => 'Sin contactos familiares';

  @override
  String get addFamilyContactsEmergency =>
      'Agregar contactos familiares para emergencias';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get phone => 'Teléfono';

  @override
  String get phoneRequired => 'El teléfono es obligatorio';

  @override
  String get emailOptional => 'Correo (Opcional)';

  @override
  String get enterValidEmail => 'Ingrese un correo válido';

  @override
  String get enter => 'Ingresar';

  @override
  String get relationship => 'Parentesco';

  @override
  String get clear => 'Limpiar';

  @override
  String get addContact => 'Agregar Contacto';

  @override
  String get familyContactsUsedBySchool =>
      'Los contactos familiares son utilizados por la escuela para emergencias';

  @override
  String get familyContactAddedSuccessfully =>
      'Contacto familiar agregado exitosamente';

  @override
  String get errorAddingContact => 'Error al agregar contacto';

  @override
  String get editContactFeatureComingSoon =>
      'Función de editar contacto próximamente';

  @override
  String get deleteContact => 'Eliminar Contacto';

  @override
  String get confirmDeleteContact =>
      '¿Estás seguro de que quieres eliminar este contacto?';

  @override
  String get contactDeleted => 'Contacto eliminado exitosamente';

  // Notification Settings - Spanish
  @override
  String get soundVibration => 'Sonido y Vibración';

  @override
  String get notificationSettingsSubtitle =>
      'Configurar preferencias de notificaciones';

  @override
  String get sound => 'Sonido';

  @override
  String get soundSubtitle => 'Configuración de sonido de notificaciones';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationSubtitle => 'Configuración de vibración';

  @override
  String get testNotification => 'Probar Notificación';

  @override
  String get notificationTone => 'Tono de Notificación';

  @override
  String get notificationInfoTitle => 'Información de Notificaciones';

  @override
  String get notificationInfoText =>
      'Configura cómo recibes las notificaciones';

  @override
  String get soundDefault => 'Predeterminado';

  @override
  String get soundBell => 'Campana';

  @override
  String get soundChime => 'Campanilla';

  @override
  String get soundSoft => 'Suave';

  @override
  String get soundClassic => 'Clásico';

  @override
  String get testNotificationWithSound => 'Probar notificación con sonido';

  @override
  String get testNotificationWithoutSound => 'Probar notificación sin sonido';

  @override
  String get withVibration => 'con vibración';

  // Personal Data - Spanish
  @override
  String get personalData => 'Datos Personales';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get firstName => 'Nombre';

  @override
  String get firstNameRequired => 'El nombre es obligatorio';

  @override
  String get lastName => 'Apellido';

  @override
  String get lastNameRequired => 'El apellido es obligatorio';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get accountInformation => 'Información de Cuenta';

  @override
  String get userType => 'Tipo de Usuario';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get registrationDate => 'Fecha de Registro';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get associatedStudents => 'Estudiantes Asociados';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get cameraFeatureComingSoon => 'Función de cámara próximamente';

  @override
  String get selectFromGallery => 'Seleccionar de Galería';

  @override
  String get galleryFeatureComingSoon => 'Función de galería próximamente';

  @override
  String get deletePhoto => 'Eliminar Foto';

  @override
  String get photoDeleted => 'Foto eliminada exitosamente';

  @override
  String get dataUpdatedSuccessfully => 'Datos actualizados exitosamente';

  @override
  String get errorUpdatingData => 'Error al actualizar datos';

  // Personal Information View - Spanish
  @override
  String get editInformation => 'Editar Información';

  @override
  String get editNameAndLastNames => 'Editar nombre y apellidos';

  @override
  String get firstNameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get lastNames => 'Apellidos';

  @override
  String get lastNamesRequired => 'Los apellidos son obligatorios';

  @override
  String get lastNamesMinLength =>
      'Los apellidos deben tener al menos 2 caracteres';

  @override
  String get currentFullName => 'Nombre completo actual';

  @override
  String get reset => 'Restablecer';

  @override
  String get saveChanges => 'Guardar';

  @override
  String get formReset => 'El formulario ha sido restablecido';

  @override
  String get personalInformationUpdatedSuccessfully =>
      'Información personal actualizada exitosamente';

  @override
  String get errorUpdatingInformation => 'Error al actualizar información';

  // Password Security - Spanish
  @override
  String get securityTips => 'Consejos de Seguridad';

  @override
  String get changePasswordSubtitle => 'Cambiar la contraseña de tu cuenta';

  @override
  String get currentPassword => 'Contraseña Actual';

  @override
  String get enterCurrentPassword => 'Ingresa tu contraseña actual';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get enterNewPassword => 'Ingresa tu nueva contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get confirmNewPassword => 'Confirmar Nueva Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get securityTip1 => 'Usa al menos 8 caracteres';

  @override
  String get securityTip2 => 'Incluye letras mayúsculas y minúsculas';

  @override
  String get securityTip3 => 'Agrega números y caracteres especiales';

  @override
  String get securityTip4 => 'No uses información personal';

  @override
  String get passwordChangedSuccessfully => 'Contraseña cambiada exitosamente';

  // Username Change - Spanish
  @override
  String get newUsername => 'Nuevo Nombre de Usuario';

  @override
  String get changeUsername => 'Cambiar Nombre de Usuario';

  @override
  String get modifyYourUniqueUsername => 'Modifica tu nombre de usuario único';

  @override
  String get currentUser => 'Usuario Actual';

  @override
  String get newUsernameLabel => 'Nuevo Nombre de Usuario';

  @override
  String get usernameRequired => 'El nombre de usuario es obligatorio';

  @override
  String get usernameMinLength =>
      'El nombre de usuario debe tener al menos 3 caracteres';

  @override
  String get usernameInvalidCharacters =>
      'El nombre de usuario solo puede contener letras, números y guiones bajos';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get passwordRequiredForConfirmation =>
      'La contraseña es obligatoria para confirmar';

  @override
  String get usernameRequirements => 'Requisitos del Nombre de Usuario';

  @override
  String get minimumCharacters => '3 caracteres mínimo';

  @override
  String get onlyLettersNumbersUnderscores =>
      'Solo letras, números y guiones bajos';

  @override
  String get mustBeUniqueInSystem => 'Debe ser único en el sistema';

  @override
  String get changeUser => 'Cambiar Usuario';

  @override
  String get important => 'Importante';

  @override
  String get usernameChangeWarning =>
      'Cambiar tu nombre de usuario puede afectar tu inicio de sesión';

  @override
  String get usernameNotAvailable => 'Nombre de usuario no disponible';

  @override
  String get usernameChangedSuccessfully =>
      'Nombre de usuario cambiado exitosamente';

  @override
  String get errorChangingUsername => 'Error al cambiar nombre de usuario';

  // Profile - Spanish
  @override
  String get myProfile => 'Mi Perfil';

  @override
  String get manageYourAccount => 'Gestiona tu cuenta';

  @override
  String get user => 'Usuario';

  @override
  String get parentRole => 'Padre/Tutor';

  @override
  String get activeDays => 'Días activos';

  @override
  String get account => 'Cuenta';

  @override
  String get editProfileAndContactData => 'Editar perfil y datos de contacto';

  @override
  String get changePasswordAndAuthentication =>
      'Cambiar contraseña y autenticación';

  @override
  String get emergencyDataAndContacts => 'Datos de emergencia y contactos';

  @override
  String get preferences => 'Preferencias';

  @override
  String get configureAlertsAndReminders =>
      'Configurar alertas y recordatorios';

  @override
  String get helpCenter => 'Centro de Ayuda';

  @override
  String get faqAndGuides => 'Preguntas frecuentes y guías';

  @override
  String get sendFeedback => 'Enviar Comentarios';

  @override
  String get shareYourExperienceWithUs =>
      'Comparte tu experiencia con nosotros';

  @override
  String get versionTermsAndPrivacy => 'Versión, términos y privacidad';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get theme => 'Tema';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get securitySettings => 'Configuración de Seguridad';

  @override
  String get securityOptionsComingSoon => 'Opciones de seguridad próximamente';

  @override
  String get understood => 'Entendido';

  @override
  String get familyInfoManagementComingSoon =>
      'Gestión de información familiar próximamente';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get helpCenterAndDocumentationComingSoon =>
      'Centro de ayuda y documentación próximamente';

  @override
  String get feedbackSystemComingSoon => 'Sistema de comentarios próximamente';

  @override
  String get aboutAlertaEscolar => 'Acerca de Alerta Escolar';

  @override
  String get aboutDescription =>
      'Alerta Escolar es una aplicación diseñada para mantener a los padres informados sobre las actividades escolares de sus hijos.';

  @override
  String get confirmSignOut => '¿Estás seguro de que quieres cerrar sesión?';

  // Reports - Spanish
  @override
  String get reportsAndStatistics => 'Reportes y Estadísticas';

  @override
  String get summary => 'Resumen';

  @override
  String get activity => 'Actividad';

  @override
  String get student => 'Estudiante';

  @override
  String get period => 'Período';

  @override
  String get selectPeriod => 'Seleccionar Período';

  @override
  String get generalSummary => 'Resumen General';

  @override
  String get lastMonth => 'Último Mes';

  @override
  String get punctuality => 'Puntualidad';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get events => 'Eventos';

  @override
  String get upcoming => 'Próximos';

  @override
  String get attendanceTrend => 'Tendencia de Asistencia';

  @override
  String get trendChartComingSoon => 'Gráfico de tendencias próximamente';

  @override
  String get noStudentsForAttendanceReport =>
      'No hay estudiantes disponibles para reporte de asistencia';

  @override
  String get attendanceReport => 'Reporte de Asistencia';

  @override
  String get noActivity => 'Sin Actividad';

  @override
  String get noNotificationsInSelectedPeriod =>
      'No hay notificaciones en el período seleccionado';

  @override
  String get activityReport => 'Reporte de Actividad';

  @override
  String get summaryByType => 'Resumen por Tipo';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get entries => 'Entradas';

  @override
  String get exits => 'Salidas';

  @override
  String get delays => 'Retrasos';

  @override
  String get absences => 'Ausencias';

  @override
  String get permissions => 'Permisos';

  @override
  String get alerts => 'Alertas';

  @override
  String get announcements => 'Anuncios';

  @override
  String get yesterday => 'Ayer';

  // Students - Spanish
  @override
  String get myStudents => 'Mis Estudiantes';

  @override
  String get registeredStudents => 'Estudiantes Registrados';

  @override
  String get noStudentsLinked => 'Sin estudiantes vinculados';

  @override
  String get loadingStudents => 'Cargando estudiantes...';

  @override
  String get errorLoadingStudents => 'Error al cargar estudiantes';

  @override
  String get retry => 'Reintentar';

  @override
  String get noStudentsRegistered => 'No hay estudiantes registrados';

  @override
  String get addFirstStudentInstructions =>
      'Agrega tu primer estudiante para comenzar a monitorear su actividad escolar';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  // Add Student - Spanish
  @override
  String get instructions => 'Instrucciones';

  @override
  String get linkStudentInstructions =>
      'Vincula un estudiante usando su código QR o código de clave proporcionado por la escuela';

  @override
  String get scanQRCode => 'Escanear Código QR';

  @override
  String get useCameraToScanQR => 'Usar cámara para escanear código QR';

  @override
  String get or => 'O';

  @override
  String get manualEntry => 'Entrada Manual';

  @override
  String get enterStudentKeyCode =>
      'Ingresar código de clave del estudiante manualmente';

  @override
  String get keyCode => 'Código de Clave';

  @override
  String get keyCodeExample => 'ej., EST123456';

  @override
  String get pleaseEnterKeyCode => 'Por favor ingresa el código de clave';

  @override
  String get keyCodeMinLength =>
      'El código de clave debe tener al menos 6 caracteres';

  @override
  String get linking => 'Vinculando';

  @override
  String get linkStudent => 'Vincular Estudiante';

  @override
  String get qrScanFunctionalityComingSoon =>
      'Funcionalidad de escaneo QR próximamente';

  @override
  String get toConfirm => 'para confirmar';

  @override
  String get studentLinkedSuccessfully => 'Estudiante vinculado exitosamente';

  @override
  String get errorLinkingStudent => 'Error al vincular estudiante';

  // Student Detail - Spanish
  @override
  String get viewSchedule => 'Ver Horario';

  @override
  String get details => 'Detalles';

  @override
  String get academicInformation => 'Información Académica';

  @override
  String get gradeLevel => 'Nivel de Grado';

  @override
  String get studentId => 'ID del Estudiante';

  @override
  String get noId => 'Sin ID';

  @override
  String get keyInformation => 'Información de Clave';

  @override
  String get notAssigned => 'No asignado';

  @override
  String get linkDate => 'Fecha de Vinculación';

  @override
  String get downloadDigitalCredential => 'Descargar Credencial Digital';

  @override
  String get editFunctionalityComingSoon =>
      'Funcionalidad de edición próximamente';

  @override
  String get deleteStudent => 'Eliminar Estudiante';

  @override
  String get studentDeletedSuccessfully => 'Estudiante eliminado exitosamente';

  // Schedule - Spanish
  @override
  String get errorLoadingSchedule => 'Error al cargar horario';

  @override
  String get classSchedule => 'Horario de Clases';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get loadingSchedule => 'Cargando horario...';

  @override
  String get noScheduledClasses => 'No hay clases programadas';

  // Methods with parameters - Spanish
  @override
  String studentsCount(int count) => '$count estudiantes';

  @override
  String studentsLinked(int count) => '$count estudiantes vinculados';

  @override
  String generatingCredentialFor(String name) =>
      'Generando credencial para $name';

  @override
  String deleteStudentConfirmation(String name) =>
      '¿Estás seguro de que quieres eliminar a $name?';

  @override
  String noClassesScheduledForDay(String day) =>
      'No hay clases programadas para $day';

  @override
  String daysAgo(int days) => 'hace $days días';

  // Missing keys for app settings - Spanish
  @override
  String get syncData => 'Sincronizar Datos';

  @override
  String get autoSync => 'Sincronización Automática';

  @override
  String get autoSyncDescription =>
      'Sincronizar datos automáticamente cuando esté conectado';

  @override
  String get offlineMode => 'Modo Sin Conexión';

  @override
  String get offlineModeDescription =>
      'Trabajar sin conexión cuando no hay conexión disponible';

  @override
  String get privacyAnalytics => 'Privacidad y Análisis';

  @override
  String get analyticsEnabled => 'Análisis Habilitado';

  @override
  String get analyticsDescription =>
      'Ayuda a mejorar la aplicación compartiendo datos de uso';

  @override
  String get crashReporting => 'Reporte de Errores';

  @override
  String get crashReportingDescription =>
      'Enviar reportes de errores para ayudar a solucionarlos';

  @override
  String get storageCache => 'Almacenamiento y Caché';

  @override
  String get cacheSize => 'Tamaño del Caché';

  @override
  String get clearCacheDescription =>
      'Limpiar caché y archivos temporales de la aplicación';

  @override
  String get downloadQuality => 'Calidad de Descarga';

  @override
  String get appUpdates => 'Actualizaciones de la Aplicación';

  @override
  String get autoUpdate => 'Actualización Automática';

  @override
  String get autoUpdateDescription =>
      'Descargar actualizaciones de la aplicación automáticamente';

  @override
  String get betaFeatures => 'Características Beta';

  @override
  String get betaFeaturesDescription =>
      'Habilitar características experimentales';

  @override
  String get appSettings => 'Configuración de la Aplicación';

  @override
  String get appConfiguration => 'Configuración de la Aplicación';

  @override
  String get low => 'Bajo';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get cacheClearError => 'Error al limpiar caché';

  // Missing keys for theme selection - Spanish
  @override
  String get themeSelection => 'Selección de Tema';

  @override
  String get chooseYourPreferredTheme => 'Elige tu tema preferido';

  @override
  String get lightModeDescription => 'Interfaz clara y limpia';

  @override
  String get darkModeDescription => 'Interfaz oscura para poca luz';

  @override
  String get systemTheme => 'Tema del Sistema';

  @override
  String get systemThemeDescription =>
      'Seguir la configuración del tema del sistema';

  // Missing keys for language selection - Spanish
  @override
  String get choosePreferredLanguage => 'Elige tu idioma preferido';

  // Missing keys for personal data navigation - Spanish
  @override
  String get managePersonalDetails => 'Gestiona tus datos personales';

  @override
  String get manageAccountData => 'Gestiona los datos de tu cuenta';

  @override
  String get passwordSecurity => 'Contraseña y Seguridad';

  @override
  String get parentAccount => 'Cuenta de Padre';

  @override
  String get administrator => 'Administrador';

  @override
  String get teacher => 'Profesor';

  @override
  String get parent => 'Padre';

  @override
  String get lastLogin => 'Último Inicio de Sesión';

  // Missing keys for home view - Spanish
  @override
  String get welcomeBack => 'Bienvenido de vuelta';

  @override
  String get newNotifications => 'nuevas';

  @override
  String get entryRegistered => 'Entrada registrada';

  @override
  String get exitRegistered => 'Salida registrada';

  @override
  String get arrivedLate => 'Llegó tarde';

  @override
  String get announcement => 'Comunicado';

  @override
  String get tapToViewDetails => 'Toca para ver detalles';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get sevenDays => '7 días';

  @override
  String get oneMonth => '1 mes';

  @override
  String get weeklyAttendance => 'Asistencia semanal';

  @override
  String get monthlyAttendance => 'Asistencia del mes';

  @override
  String get plusFivePercent => '+5% vs anterior';

  @override
  String get plusTwoPercent => '+2% vs anterior';

  @override
  String get attendances => 'Asistencias';

  @override
  String get lateArrivals => 'Tardanzas';

  @override
  String get todaysSchedule => 'Horario de hoy';

  @override
  String get morningClasses => 'Clases matutinas';

  @override
  String get afternoonClasses => 'Clases vespertinas';

  @override
  String get extracurricularActivities => 'Actividades extracurriculares';

  @override
  String get mathSpanishSciences => 'Matemáticas, Español, Ciencias';

  @override
  String get historyPhysicalEducation => 'Historia, Educación Física';

  @override
  String get chessClub => 'Club de ajedrez';

  @override
  String get inProgress => 'En curso';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get notificationsWillAppearHere =>
      'Las notificaciones aparecerán aquí';

  @override
  String get addStudentToStart => 'Agrega un estudiante para comenzar';

  // Missing keys for notifications view - Spanish
  @override
  String get categories => 'Categorías';

  @override
  String get accessAlerts => 'Alertas de Acceso';

  @override
  String get fourteenDays => '14 días';

  @override
  String get accessRecordsAndAlerts => 'registros de acceso y alertas';

  // Schedule view additional keys - Spanish
  @override
  String get weeklySchedule => 'Horario Semanal';

  // Student selection - Spanish
  @override
  String get selectStudent => 'Seleccionar Estudiante';

  // Family relationship types - Spanish
  @override
  String get father => 'Padre';

  @override
  String get mother => 'Madre';

  @override
  String get grandfather => 'Abuelo';

  @override
  String get grandmother => 'Abuela';

  @override
  String get guardian => 'Tutor';

  @override
  String get guardianFemale => 'Tutora';

  @override
  String get uncle => 'Tío';

  @override
  String get aunt => 'Tía';

  @override
  String get brother => 'Hermano';

  @override
  String get sister => 'Hermana';

  @override
  String get otherFamily => 'Otro Familiar';
}
