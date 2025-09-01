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
    // if (kDebugMode) {
    //   print(
    //       'Warning: No AppLocalizations found in context. Using English fallback. '
    //       'Make sure to include AppLocalizations.delegate in your app\'s localizationsDelegates.');
    // }
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

  String get selectTime;
  String get hours;
  String get ok;
  String get noSchedulesAvailable;
  String noClassesForDay(String day);
  String get noSchedulesConfiguredForGroup;
  String get noClassesScheduledForThisDay;
  String get allStatuses;
  String get searchByDateStaffOrLocation;
  String get searchFilters;
  String get id;
  String get startTime;
  String get endTime;
  String studentCountOf(int count);
  String get arrivedAt;
  String get signUpEmailRegistered;
  String get emailInvalid;
  String get emailAlreadyExists;
  String get loggingIn;
  String get verifyingCode;
  String get resendingCode;
  String get registering;
  String get settingUpAccount;
  String get loading;
  String get signInCanceled;
  String get registerCanceled;
  String get appleNotAvailable;
  String get sessionExpiredOrNoUser;

  String get credentialSavedSuccessfully;
  String get errorSavingCredential;

  String get refresh;

// Time related
  String get timeSeparator;
  String get am;
  String get pm;
  String get tapToOpenCamera;

// QR Scanner
  String get qrScannerPointCamera;
  String get qrScannerTitle;
  String get qrScannerAutomatic;
  String get scanAnother;
  String get cameraScanner;

// Student Records
  String attendanceRecordOf(String name);
  String get delayedEntry;
  String get lastFiveRecords;
  String get entryRecords;
  String get delayedEntries;
  String get exitRecords;

// Class Schedule
  String durationInMinutes(int minutes);
  String get classroom;
  String get classDetails;

// Student Information
  String get defaultStudentInitial;
  String studentGradeAndGroup(String grade, String group);
  String get linkedTutor;
  String get linkedTutors;
  String get informationNotAvailable;
  String get noTimeLimit;
  String get expired;
  String get oneDayRemaining;
  String daysRemaining(int days);
  String get oneHourRemaining;
  String hoursRemaining(int hours);
  String get oneMinuteRemaining;
  String minutesRemaining(int minutes);
  String get lessThanOneMinuteRemaining;

// School Subjects
  String get break_;
  String get mathematics;
  String get naturalSciences;
  String get history;
  String get physicalEducation;
  String get art;

// Scanner Configuration
  String get automaticEntry;
  String get automaticExit;
  String get unauthenticatedUser;
  String get schoolNotIdentified;
  String errorLoadingConfiguration(String error);

// Notifications and Messages
  String get reviewMessage;
  String get officialCommunication;
  String get reviewCarefullyBeforeContinuing;
  String get communicationDetails;
  String get type;

// Error Messages
  String internalError(String error);
  String get couldNotGetUserSchool;
  String get errorLoadingStats;
  String get errorLoadingData;

// Filters and Headers
  String get filters;
  String get attendanceDate;
// Contact information
  String get noFamilyContactsRegistered;
  String get noName;
  String get noRelationship;

// General
  String get date;
  String get title;
  // QR Scanner related strings
  String get qrScannerPlaceholder;
  String get qrScannerInstructions;
  String get qrScannerBottomInstructions;

  // Student validation strings
  String get validatingCode;
  String get validateCode;
  String get invalidStudentCode;
  String get errorValidatingCode;
  String get userNotFound;
  String get studentRegisteredSuccessfully;
  String get errorRegisteringStudent;

  // Student confirmation dialog strings
  String get confirmStudentRegistration;
  String get studentToRegister;
  String get gradeGroup;
  String get confirmRegistrationMessage;
  String get confirmRegistration;

  String get loadingFamilyContacts;
  String get loadingNotifications;

  String get error;
  String get loadingSchoolInformation;
  String get errorFetchingSchool;
  String get errorLoadingSchool;
  String get updatingSchoolInformation;
  String get errorUpdatingSchool;
  String get noAssociatedSchool;
  String get errorLoadingSchoolInfo;
  String get requiredFields;
  String get pleaseCompleteFields;
  String get couldNotGetSchoolInfo;
  String get unknownError;
  String get errorSavingChanges;

  String get editContact;
  String get name;
  String get enterContactName;
  String get enterPhoneNumber;
  String get enterEmail;
  String get contactUpdatedSuccessfully;
  String get errorUpdatingContact;

  String get updatingContact;
  String get deletingContact;
  String get savingContact;

  String get associatedSchool;
  String get accountType;
  String get unverified;
  String get administrativeRole;
  String get todayAt;
  String get yesterdayAt;
  String get administratorAccount;
  String get adminAccountInformation;

  String get loadingUserData;
  String get updatingPersonalInfo;

  String get myProfile;
  String get manageYourAccount;
  String get user;
  String get parentRole;
  String get fatherRole;
  String get motherRole;
  String get tutorRole;
  String get relativeRole;
  String get adminRole;

  String get neverConnected;
  String get school;
  String get director;
  String get subdirector;
  String get secretary;
  String get securityStaff;
  String get teacher;
  String get administrative;
  String get administrativo;
  String get administrator;
  String get parent;
  String get student;

  // Authentication related strings
  String get verificationSuccessful;
  String get completeYourProfile;
  String get loginSuccessful;
  String get appleSignInError;
  String get googleSignInError;
  String get accountSetupSuccessfully;
  String get unexpectedError;
  String get logoutSuccessful;
  String get logoutError;

  // Relationship related strings
  String get relationshipType;
  String get selectYourRelationshipWithStudent;
  String get tutor;
  String get relative;
  // Authentication and intro related
  String get alertaEscolar;
  String get introWelcomeMessage;
  String get introFooterText;
  String get qrAttendanceFeature;
  String get realTimeNotificationsFeature;
  String get securityFeature;
  String get getStarted;
  String get learnMore;
  String get alertaEscolarDescription;
  String get login;
  String get registerWithEmail;
  String get magicLinkSent;
  String get pleaseCreateAccount;

// Missing authentication-related getters
  String get continueWithGoogle;
  String get signingInWithGoogle;
  String get joinUs;
  String get signUpWithGoogle;
  String get signingUpWithGoogle;
  String get signUpWithApple;
  String get signingUpWithApple;
  String get continueWithApple;
  String get signingInWithApple;
  String get changeEmail;
  String get returnToStart;
// Login related
  String get loginErrorMessage;
  String get signIn;
  String get password;
  String get passwordTooShort;
  String get rememberMe;
  String get forgotPassword;
  String get signingIn;
  String get loginSubtitle;

// Login footer
  String get dontHaveAccount;
  String get signUp;
  String get privacyPolicy;
  String get termsOfService;
  String get versionInfo;

// Login options
  String get continueAsGuest;
  String get guestAccessDescription;
  String get guestAccess;
  String get guestAccessWarning;
  String get continue_;

// Signup related
  String get mustAcceptTerms;
  String get signUpErrorMessage;
  String get createAccount;
  String get phoneNumber;
  String get iAcceptThe;
  String get and;
  String get creatingAccount;
  String get joinAlertaEscolar;
  String get signUpSubtitle;
  String get selectUserType;

// Signup footer
  String get alreadyHaveAccount;
  String get needHelp;
  String get contactSupport;

// Signup options
  String get haveSchoolCode;
  String get schoolCodeDescription;
  String get enterSchoolCode;
  String get invalidSchoolCode;
  String get enterSchoolCodeHint;
  String get schoolCodeInfo;
  String get verifying;
  String get verify;

// Account setup
  String get pleaseEnterFullName;
  String get accountSetupSuccessful;
  String get errorSettingUpAccount;
  String get welcomeToAlertaEscolar;
  String get pleaseCompleteYourProfile;
  String get setting;
  String get continueText;
  String get thisInformationWillBeUsedForYourProfile;

// Verification
  String get enterCompleteCode;
  String get codeVerifiedSuccessfully;
  String get invalidVerificationCode;
  String get codeResentSuccessfully;
  String get errorResendingCode;
  String get verifyCode;
  String get enterVerificationCode;
  String get resending;
  String get resendCode;
  String get verificationRequired;
  String get codeSentTo;
  String get verificationCodeHelpText;

// Theme selection
  String get selectTheme;
  String get lightTheme;
  String get lightThemeDescription;
  String get darkTheme;
  String get darkThemeDescription;
  String get apply;

  // Days of week short names
  String get mondayShort;
  String get tuesdayShort;
  String get wednesdayShort;
  String get thursdayShort;
  String get fridayShort;
  String get saturdayShort;
  String get sundayShort;

  // Attendance status keys
  String get presentStatusKey;
  String get lateStatusKey;

  // Location related
  String get mainEntrance;
  String get secondaryEntrance;
  String get lateArrival;
  String get notification;
  String get shift;
  String get access;
  String get both;
  String get justified;

  // Message helpers with student parameter
  String studentArrivalMessage(String name);
  String studentExitMessage(String name);
  String studentLateMessage(String name);
  String notificationForStudent(String name);
  String studentLateArrivalMessage(String name);

  // Admin dashboard actions
  String get mainActions;
  String get manageAnnouncementsAndSchedules;
  String get sendAnnouncement;
  String get sendNotificationsToStudents;
  String get viewSchedules;
  String get manageClassSchedules;

  // Time formatting
  String dateFormat(DateTime date);
  String timeFormat(DateTime time);
  String dateFormatFull(DateTime date);

  // Time ago helpers
  String get timeAgoNow;
  String timeAgoMinutes(int minutes);
  String timeAgoHours(int hours);
  String timeAgoDays(int days);
  String minutesAgo(int minutes);
  String hoursAgo(int hours);

  // Students directory related
  String get studentDirectory;
  String studentsCountOf(int count, String filter);
  String studentCount(int count);
  String get total;
  String get noStudentsFoundWithFilters;
  String get noRegisteredStudents;
  String get studentsWillAppearWhenRegistered;
  String get noDataForFutureDates;
  String get noScanRecordsForDate;
  String get studentsWillAppearWhenScanned;

  // QR scanner related
  String get tapScanAreaToSimulate;

  // Student info
  String get remainingTime;
  String get thirtyDays;
  String get statisticsFor;
  String get daysOfWeek;
  String get editStudentInfoInstructions;
  String get contactSchoolFeatureComingSoon;
  String get contactSchool;
  String get startScanningDefaultMessage;
  // Scanner configuration
  String get scannerConfiguration;
  String get schedules;
  String get tolerance;
  String get previous;
  String get next;
  String get saveConfiguration;
  String get configurationSavedSuccessfully;

  // Contact info
  String openContactInfo(String contactName);

  // School information fields
  String get educationalLevels;
  String get manageAndViewYourStudents;
  String get manageAndSearchStudents;
  String get information;
  String get public;
  String get private;
  String get mixed;
  String get preschool;
  String get primary;
  String get secondary;
  String get highSchool;
  String get educationalLevel;
  String get institution;
  String get address;
  String get schoolDescription;
  String get educationalExcellenceInstitution;
  String get experienceLabel;
  String yearsExperience(int years);
  String get imageUploadSoonAvailable;
  String errorSaving(String entity);

  String get messageType;
  String get requestSpecialPermissionDesc;
  String get communication;
  String get sendOfficialCommunicationDesc;
  String get communicationType;
  String get recipients;
  String get individualStudent;
  String get selectSpecificStudent;
  String get groupClass;
  String get sendToEntireClass;
  String get entireShift;
  String get allStudentsInShift;
  String get entireEducationalInstitution;
  String get deliveryOptions;
  String get pushNotification;
  String get sendImmediateNotificationToDevice;
  String get sendCommunication;
  String get sendNow;
  String get scheduled;
  String get sentSuccessfully;

  // Basic app strings
  String get appTitle;
  String get homeTitle;
  String get attendance;
  String get notifications;
  String get profile;
  String get students;
  String get settings;
  String get darkMode;
  String get language;
  String get spanish;
  String get english;
  String get welcome;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get viewAll;
  String get present;
  String get absent;
  String get late;
  String get today;
  String get cancel;
  String get close;
  String get undo;
  String get save;
  String get edit;
  String get delete;
  String get add;
  String get grade;
  String get noData;

  // Admin schedule management
  String get filterByDay;
  String get all;
  String get schedulesByGroup;
  String get selectClass;
  String get chooseClassForNotification;
  String get classSelected;
  String get tapToChooseClass;
  String get selectShift;
  String get selectShiftToSend;
  String get chooseShiftToReceiveNotification;
  String get shiftSelected;
  String get tapToChooseShift;
  String get classes;
  String get morning;
  String get afternoon;
  String get entry;
  String get exit;
  String get after;
  String get tapToChange;
  String get configureShiftSchedules;
  String get setEntryExitHoursForShifts;
  String get ofTolerance;
  String get adjustTolerance;
  String get min;
  String get quickSelection;
  String get toleranceForLateArrivals;
  String get needScheduleChanges;
  String get scheduleChangesDescription;
  String get calendarExplanationText;

  // Admin notifications
  String get informative;
  String get fieldTrip;
  String get emergency;
  String get event;
  String get paymentReminder;
  String get citation;
  String get celebration;
  String get classSuspension;
  String get scheduleChange;
  String get critical;
  String get low;
  String get medium;
  String get high;
  String get exampleCommunicationTitle;
  String get examplePermissionTitle;
  String get message;
  String get communicationContentHint;
  String get messageContentHint;
  String get communicationTip;
  String get messageTip;
  String get selectStudentFromDirectory;
  String get searchInDirectory;
  String get navigateToStudentDirectory;

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
  String get alert => 'Alert';
  String get general => 'General';
  String get recentNotifications => 'Recent Notifications';
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

  // QR and notifications
  String get scanQRToRegisterAttendance => 'Scan QR to Register Attendance';
  String get sendNotification => 'Send Notification';
  String get scanning => 'Scanning';
  String get scanningActive => 'Scanning Active';
  String get readyToScan => 'Ready to Scan';
  String get stopScanning => 'Stop Scanning';

  // School settings
  String get selectColor => 'Select Color';
  String get basicInformation => 'Basic Information';
  String get principal => 'Principal';
  String get institutionalConfiguration => 'Institutional Configuration';
  String get schoolType => 'School Type';
  String get educationLevels => 'Education Levels';
  String get selectEducationLevels => 'Select Education Levels';
  String get selectAtLeastOneLevel => 'Select at least one level';
  String get aboutSchool => 'About School';

  // Student records
  String get noRecordsFound => 'No Records Found';
  String get tryAdjustingFilters => 'Try adjusting filters';
  String get detailedRecords => 'Detailed Records';
  String get searchStudent => 'Search Student';

  // Additional missing keys for admin components
  String get selectRecipient => 'Select Recipient';
  String get enterMessageTitle => 'Enter message title';
  String get titleRequired => 'Title is required';
  String get enterMessageContent => 'Enter message content';
  String get contentRequired => 'Content is required';
  String get sending => 'Sending';
  String get attendanceFor => 'Attendance for';
  String get totalStudents => 'Total Students';
  String get absentStudents => 'Absent Students';
  String get calendarLegend => 'Calendar Legend';
  String get fullAttendance => 'Full Attendance';
  String get partialAttendance => 'Partial Attendance';
  String get lowAttendance => 'Low Attendance';
  String get noClasses => 'No Classes';

  // Attendance methods with parameters
  String attendanceRecordsCount(int count) => '$count attendance records';
  String noRecordsForDate(String date) => 'No records for $date';
  String attendanceForDate(String date) => 'Attendance for $date';
  String gradeLabel(String grade) => 'Grade $grade';
  String attendancePercentage(int percentage, String status) =>
      '$percentage% - $status';
  String fullDateFormat(int day, String month, int year) =>
      '$month $day, $year';
  String studentsHaveToleranceAfterEntryTime(int minutes) =>
      'Students have $minutes minutes of tolerance after entry time';
  String recordCount(int count) => '$count records';
  String contactVia(String method) => 'Contact via $method';
  String scheduleOf(String name) => 'Schedule of $name';

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
  String get noChangesDetected;

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
  String get verification;

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
  String get guardianFemale => 'Guardian';
  String get uncle => 'Uncle';
  String get aunt => 'Aunt';
  String get brother => 'Brother';
  String get sister => 'Sister';
  String get otherFamily => 'Other Family';

  // Admin module keys
  String get adminDashboard => 'Admin Dashboard';
  String get attendanceControl => 'Attendance Control';
  String get studentsDirectory => 'Students Directory';
  String get scheduleManagement => 'Schedule Management';
  String get schoolSettings => 'School Settings';
  String get reports => 'Reports';
  String get scanQR => 'Scan QR';
  String get attendanceRegistered => 'Attendance Registered';
  String get createAnnouncement => 'Create Announcement';
  String get sendToGroup => 'Send to Group';
  String get sendToStudent => 'Send to Student';
  String get messageTitle => 'Message Title';
  String get messageContent => 'Message Content';
  String get selectGrade => 'Select Grade';
  String get selectGroup => 'Select Group';
  String get priority => 'Priority';
  String get urgent => 'Urgent';
  String get send => 'Send';
  String get announcementSent => 'Announcement Sent';
  String get todayAttendance => 'Today\'s Attendance';
  String get totalScanned => 'Total Scanned';
  String get presentStudents => 'Present Students';
  String get lateStudents => 'Late Students';
  String get scannedBy => 'Scanned by';
  String get scanTime => 'Scan Time';
  String get entryTime => 'Entry Time';
  String get searchStudents => 'Search Students';
  String get filterBy => 'Filter by';
  String get allGrades => 'All Grades';
  String get allGroups => 'All Groups';
  String get activeStudents => 'Active Students';
  String get inactiveStudents => 'Inactive Students';
  String get studentsFound => 'Students Found';
  String get noStudentsFound => 'No Students Found';
  String get studentProfile => 'Student Profile';
  String get familyContacts => 'Family Contacts';
  String get attendanceHistory => 'Attendance History';
  String get academicRecord => 'Academic Record';
  String get contactParents => 'Contact Parents';
  String get editStudent => 'Edit Student';
  String get turn => 'Turn';
  String get morningShift => 'Morning Shift';
  String get afternoonShift => 'Afternoon Shift';
  String get activated => 'Activated';
  String get deactivated => 'Deactivated';
  String get timeRemaining => 'Time Remaining';
  String get days => 'Days';
  String get entryTolerance => 'Entry Tolerance';
  String get lateTolerance => 'Late Tolerance';
  String get exitTime => 'Exit Time';
  String get configureSchedules => 'Configure Schedules';
  String get schoolInfo => 'School Information';
  String get schoolName => 'School Name';
  String get schoolAddress => 'School Address';
  String get schoolPhone => 'School Phone';
  String get schoolEmail => 'School Email';
  String get principalName => 'Principal Name';
  String get schoolLogo => 'School Logo';
  String get schoolColors => 'School Colors';
  String get primaryColor => 'Primary Color';
  String get secondaryColor => 'Secondary Color';
  String get accentColor => 'Accent Color';
  String get updateSettings => 'Update Settings';
  String get settingsUpdated => 'Settings Updated';
  String get selectDateRange => 'Select Date Range';
  String get startDate => 'Start Date';
  String get endDate => 'End Date';
  String get generateReport => 'Generate Report';
  String get exportReport => 'Export Report';
  String get attendanceRate => 'Attendance Rate';
  String get punctualityRate => 'Punctuality Rate';
  String get absenceRate => 'Absence Rate';
  String get totalDays => 'Total Days';
  String get presentDays => 'Present Days';
  String get lateDays => 'Late Days';
  String get absentDays => 'Absent Days';
  String get monthlyReport => 'Monthly Report';
  String get weeklyReport => 'Weekly Report';
  String get dailyReport => 'Daily Report';
  String get byGrade => 'By Grade';
  String get byGroup => 'By Group';
  String get byStudent => 'By Student';
  String get attendanceCalendar => 'Attendance Calendar';
  String get viewDetails => 'View Details';
  String get scannedStudents => 'Scanned Students';

  String get lastStudentScanned => 'Last Student Scanned';
  String get unknown => 'Unknown';
  String get now => 'Now';
  String get startScanningToSeeRecords => 'Start scanning to see records';
  String get noStudentsScanned => 'No students scanned';
  String get noAttendanceThisDate => 'No attendance for this date';
  String get totalAnnouncementsSent => 'Total announcements sent';
  String get read => 'Read';
  String get delivered => 'Delivered';
  String get pending => 'Pending';
  String get failed => 'Failed';
  String get noAnnouncementsSent => 'No announcements sent';
  String get createFirstAnnouncement => 'Create your first announcement';

  // Additional admin localization keys
  String get contacts => 'Contacts';
  String get primaryContact => 'Primary Contact';
  String get occupation => 'Occupation';
  String get emergencyContact => 'Emergency Contact';
  String get recentRecords => 'Recent Records';
  String get last30Days => 'Last 30 Days';
  String get viewAllRecords => 'View All Records';
  String get adminActions => 'Admin Actions';
  String get primaryActions => 'Primary Actions';
  String get communicationActions => 'Announcement Actions';
  String get administrativeActions => 'Administrative Actions';
  String get emergencyActions => 'Emergency Actions';
  String get sendMessage => 'Send Message';
  String get sendEmail => 'Send Email';
  String get addNote => 'Add Note';
  String get scheduleCall => 'Schedule Call';
  String get printProfile => 'Print Profile';
  String get contact => 'Contact';
  String get schedule => 'Schedule';
  String get generate => 'Generate';
  String get print => 'Print';
  String get completedSuccessfully => 'Completed Successfully';
  String get emergencyContactInitiated => 'Emergency Contact Initiated';
  String get contactParentsConfirm => 'Contact parents?';
  String get sendMessageConfirm => 'Send message to parents?';
  String get sendEmailConfirm => 'Send email to parents?';
  String get addNoteConfirm => 'Add note to student record?';
  String get scheduleCallConfirm => 'Schedule call with parents?';
  String get generateReportConfirm => 'Generate student report?';
  String get printProfileConfirm => 'Print student profile?';
  String get emergencyContactConfirm => 'Initiate emergency contact protocol?';
  String get editStudentConfirm => 'Edit student information?';
  String get directoryStats => 'Directory Statistics';
  String get newThisMonth => 'New This Month';
  String get grades => 'Grades';
  String get groups => 'Groups';
  String get searchByNameOrId => 'Search by name or ID';
  String get searchTip => 'Search tip';
  String get searchByName => 'Search by name';
  String get searchById => 'Search by ID';
  String get searchByGrade => 'Combine with filters';
  String get clearFilters => 'Clear Filters';
  String get allStatus => 'All Status';
  String get activeFilters => 'Active Filters';
  String get tryDifferentFilters => 'Try different filters or search terms';
  String get registeredOn => 'Registered on';
  String get timeSettings => 'Time Settings';
  String get toleranceSettings => 'Tolerance Settings';
  String get minutes => 'Minutes';
  String get selectGradeAndGroup => 'Select Grade and Group';
  String get editingScheduleFor => 'Editing schedule for';
  String get subject => 'Subject';
  String get editSubject => 'Edit Subject';
  String get scheduleReset => 'Schedule Reset';
  String get scheduleSaved => 'Schedule Saved';
  String get contactInfo => 'Contact Information';
  String get emergencyPhone => 'Emergency Phone';
  String get website => 'Website';
  String get socialMedia => 'Social Media';
  String get invalidEmail => 'Invalid Email';
  String get fieldRequired => 'This field is required';
  String get saving => 'Saving';
  String get schoolBranding => 'School Branding';
  String get schoolCode => 'School Code';
  String get foundedYear => 'Founded Year';
  String get description => 'Description';
  String get changeLogo => 'Change Logo';
  String get uploadLogo => 'Upload Logo';
  String get logoUploaded => 'Logo Uploaded';
  String get noLogoUploaded => 'No Logo Uploaded';
  String get preview => 'Preview';

  // Report-related keys
  String get selectReportType => 'Select Report Type';
  String get attendanceReportDesc => 'Detailed attendance report by period';
  String get punctualityReport => 'Punctuality Report';
  String get punctualityReportDesc => 'Analysis of tardiness and punctuality';
  String get absenceReport => 'Absence Report';
  String get absenceReportDesc => 'Statistics of school absenteeism';
  String get summaryReport => 'Summary Report';
  String get summaryReportDesc => 'Overview of all metrics';
  String get reportFilters => 'Report Filters';
  String get reportPeriod => 'Report Period';
  String get customPeriod => 'Custom Period';
  String get exportAs => 'Export as';
  String get exportConfirm => 'The report will be exported in format';
  String get export => 'Export';
  String get exporting => 'Exporting';
  String get generating => 'Generating';
  String get exportedSuccessfully => 'Exported successfully in format';
  String get pdfExportDesc => 'PDF document for printing';
  String get excelExportDesc => 'Excel spreadsheet';
  String get imageExportDesc => 'Image for presentations';
  String get shareReportDesc => 'Share report directly';
  String get reportGenerationConfirm =>
      'Generate report with selected filters?';
  String get reportGenerated => 'Report generated successfully';
  String get share => 'Share';

  // Missing getters
  String get attendanceList => 'Attendance List';
  String get time => 'Time';
  String get group => 'Group';
  String get status => 'Status';
  String get selectExportFormat => 'Select Export Format';
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
  String get selectTime => 'Select Time';

  @override
  String get hours => 'Hours';

  @override
  String get pleaseCreateAccount => 'Please create an account to continue';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get emailAlreadyExists => 'This email address is already registered';

  @override
  String get ok => 'OK';
  @override
  String get loadingFamilyContacts => 'Loading family contacts...';

  @override
  String get loadingNotifications => 'Loading notifications...';

  @override
  String get appleNotAvailable =>
      'Apple Sign-In is not available on this device';

  // Time related
  @override
  String get timeSeparator => ':';
  @override
  String get am => 'AM';
  @override
  String get pm => 'PM';

  @override
  String get refresh => 'Refresh';

  @override
  String get credentialSavedSuccessfully => 'Credential saved successfully';

  @override
  String get errorSavingCredential => 'Error saving credential';

  @override
  String get sessionExpiredOrNoUser =>
      'Session expired or no user is signed in. Please sign in again.';
  @override
  String get tapToOpenCamera => 'Tap to open the camera';

  @override
  String get signInCanceled => 'Sign-in process canceled';

  @override
  String get registerCanceled => 'Registration process canceled';

// QR Scanner
  @override
  String get qrScannerPointCamera => 'Point camera at student\'s QR code';
  @override
  String get qrScannerTitle => 'Scan QR Code';
  @override
  String get qrScannerAutomatic =>
      'Position QR code within frame to scan automatically';
  @override
  String get scanAnother => 'Scan Another';
  @override
  String get cameraScanner => 'Camera Scanner';

// Student Records
  @override
  String attendanceRecordOf(String name) => 'Attendance record of $name';
  @override
  String get delayedEntry => 'Delayed Entry';
  @override
  String get lastFiveRecords => 'Last 5 Records';
  @override
  String get entryRecords => 'Entry Records';
  @override
  String get delayedEntries => 'Delayed Entries';
  @override
  String get exitRecords => 'Exit Records';

// Class Schedule
  @override
  String durationInMinutes(int minutes) => '$minutes minutes';
  @override
  String get classroom => 'Classroom';
  @override
  String get classDetails => 'Class Details';

// Student Information
  @override
  String get defaultStudentInitial => 'S';
  @override
  String studentGradeAndGroup(String grade, String group) =>
      'Grade $grade Group $group';
  @override
  String get linkedTutor => 'Linked Tutor';
  @override
  String get linkedTutors => 'Linked Tutors';
  @override
  String get informationNotAvailable => 'Information not available';
  @override
  String get noTimeLimit => 'No time limit';
  @override
  String get expired => 'Expired';
  @override
  String get oneDayRemaining => 'One day remaining';
  @override
  String daysRemaining(int days) => '$days days remaining';
  @override
  String get oneHourRemaining => 'One hour remaining';
  @override
  String hoursRemaining(int hours) => '$hours hours remaining';
  @override
  String get oneMinuteRemaining => 'One minute remaining';
  @override
  String minutesRemaining(int minutes) => '$minutes minutes remaining';
  @override
  String get lessThanOneMinuteRemaining => 'Less than one minute remaining';

// School Subjects
  @override
  String get break_ => 'Break';
  @override
  String get mathematics => 'Mathematics';
  @override
  String get naturalSciences => 'Natural Sciences';
  @override
  String get history => 'History';
  @override
  String get physicalEducation => 'Physical Education';
  @override
  String get art => 'Art';

// Scanner Configuration
  @override
  String get automaticEntry => 'Automatic Entry';
  @override
  String get automaticExit => 'Automatic Exit';
  @override
  String get unauthenticatedUser => 'Unauthenticated User';
  @override
  String get schoolNotIdentified => 'School not identified';
  @override
  String errorLoadingConfiguration(String error) =>
      'Error loading configuration: $error';

// Notifications and Messages
  @override
  String get reviewMessage => 'Review Message';
  @override
  String get officialCommunication => 'Official Communication';
  @override
  String get reviewCarefullyBeforeContinuing =>
      'Please review carefully before continuing';
  @override
  String get communicationDetails => 'Communication Details';
  @override
  String get type => 'Type';

// Error Messages
  @override
  String internalError(String error) => 'Internal Error: $error';
  @override
  String get couldNotGetUserSchool => 'Could not get user\'s school';
  @override
  String get errorLoadingStats => 'Error loading statistics';
  @override
  String get errorLoadingData => 'Error loading data';

// Filters and Headers
  @override
  String get filters => 'Filters';
  @override
  String get attendanceDate => 'Attendance Date';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get name => 'Name';

  @override
  String get qrScannerPlaceholder => 'Point camera at QR code';

  @override
  String get qrScannerInstructions =>
      'Align the QR code within the frame to scan';

  @override
  String get qrScannerBottomInstructions =>
      'Make sure the QR code is well lit and visible';

  // Student validation strings - English
  @override
  String get validatingCode => 'Validating code...';

  @override
  String get validateCode => 'Validate Code';

  @override
  String get invalidStudentCode => 'Invalid student code';

  @override
  String get errorValidatingCode => 'Error validating code';

  @override
  String get userNotFound => 'User not found';

  @override
  String get studentRegisteredSuccessfully => 'Student registered successfully';

  @override
  String get errorRegisteringStudent => 'Error registering student';

  // Student confirmation dialog strings - English
  @override
  String get confirmStudentRegistration => 'Confirm Student Registration';

  @override
  String get studentToRegister => 'Student to Register';

  @override
  String get gradeGroup => 'Grade/Group';

  @override
  String get confirmRegistrationMessage =>
      'Are you sure you want to register this student?';

  @override
  String get confirmRegistration => 'Confirm Registration';

  @override
  String get enterContactName => 'Enter contact name';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get enterEmail => 'Enter email address';

  @override
  String get error => 'Error';

  @override
  String get loadingSchoolInformation => 'Loading school information...';

  @override
  String get errorFetchingSchool => 'Error fetching school information';

  @override
  String get errorLoadingSchool => 'Error loading school data';

  @override
  String get updatingSchoolInformation => 'Updating school information...';

  @override
  String get errorUpdatingSchool => 'Error updating school information';

  @override
  String get noAssociatedSchool => 'No associated school found';

  @override
  String get errorLoadingSchoolInfo => 'Error loading school information';

  @override
  String get requiredFields => 'Required Fields';

  @override
  String get pleaseCompleteFields => 'Please complete all required fields';

  @override
  String get couldNotGetSchoolInfo => 'Could not get school information';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get errorSavingChanges => 'Error saving changes';

  @override
  String get contactUpdatedSuccessfully => 'Contact updated successfully';

  @override
  String get errorUpdatingContact => 'Error updating contact';

  @override
  String get updatingContact => 'Updating contact...';

  @override
  String get deletingContact => 'Deleting contact...';

  @override
  String get savingContact => 'Saving contact...';

  @override
  String get noChangesDetected => 'No changes detected';

  @override
  String get loadingUserData => 'Loading user data...';
  @override
  String get updatingPersonalInfo => 'Updating personal information...';

  @override
  String get associatedSchool => 'Associated School';
  @override
  String get accountType => 'Account Type';
  @override
  String get unverified => 'Unverified';
  @override
  String get administrativeRole => 'Administrative Role';
  @override
  String get todayAt => 'Today at';
  @override
  String get yesterdayAt => 'Yesterday at';
  @override
  String get administratorAccount => 'Administrator Account';
  @override
  String get adminAccountInformation =>
      'You have administrator privileges. You can access and manage school information, students, and security settings.';

  @override
  String get neverConnected => 'Never connected';
  @override
  String get school => 'School';
  @override
  String get director => 'Principal';
  @override
  String get subdirector => 'Vice Principal';
  @override
  String get secretary => 'Secretary';
  @override
  String get securityStaff => 'Security Staff';
  @override
  String get teacher => 'Teacher';
  @override
  String get administrative => 'Administrative';
  @override
  String get administrativo => 'Administrative';
  @override
  String get administrator => 'Administrator';
  @override
  String get parent => 'Parent';
  @override
  String get student => 'Student';

  @override
  String get noSchedulesAvailable => 'No schedules available';

  @override
  String get registering => 'Registering...';

  @override
  String get resendingCode => 'Resending code...';

  @override
  String noClassesForDay(String day) => 'No classes for $day';

  @override
  String get noSchedulesConfiguredForGroup =>
      'No schedules configured for this group';

  @override
  String get noClassesScheduledForThisDay =>
      'No classes scheduled for this day';
  @override
  String get allStatuses => 'All Statuses';

  @override
  String get myProfile => 'My Profile';
  @override
  String get manageYourAccount => 'Manage your account';
  @override
  String get user => 'User';
  @override
  String get parentRole => 'Parent';
  @override
  String get fatherRole => 'Father';
  @override
  String get motherRole => 'Mother';
  @override
  String get tutorRole => 'Tutor';
  @override
  String get relativeRole => 'Family Member';
  @override
  String get adminRole => 'Administrator';

  @override
  String get searchByDateStaffOrLocation => 'Search by date, staff or location';

  @override
  String get searchFilters => 'Search Filters';

  @override
  String get id => 'ID';

  @override
  String get loading => 'Loading...';

  @override
  String get settingUpAccount => 'Setting up account...';

  // Add implementations to AppLocalizationsEn class:

  @override
  String get verificationSuccessful => 'Verification successful';

  @override
  String get completeYourProfile => 'Please complete your profile';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get appleSignInError => 'There was a problem signing in with Apple';

  @override
  String get googleSignInError => 'There was a problem signing in with Google';

  @override
  String get accountSetupSuccessfully => 'Account setup completed successfully';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get logoutSuccessful => 'Logout successful';

  @override
  String get logoutError => 'There was a problem signing out';

  @override
  String get relationshipType => 'Relationship Type';

  @override
  String get selectYourRelationshipWithStudent =>
      'Select your relationship with the student';

  @override
  String get tutor => 'Tutor';

  @override
  String get relative => 'Relative';

  @override
  String get signUpEmailRegistered => 'This email is already registered';

  @override
  String get magicLinkSent => 'Magic link sent! Check your email to continue.';

  @override
  String get alertaEscolar => 'School Alert';
  @override
  String get loggingIn => 'Logging in...';

  @override
  String get verifyingCode => 'Verifying code...';

  @override
  String get introWelcomeMessage =>
      'Stay connected with your child\'s school activities';

  @override
  String get introFooterText =>
      'Discover all the features that will help you stay informed about your child\'s education';

  @override
  String get qrAttendanceFeature =>
      'QR code attendance tracking for quick and accurate check-ins';

  @override
  String get verification => 'Verification';

  @override
  String get realTimeNotificationsFeature =>
      'Instant notifications for arrivals, departures, and important announcements';

  @override
  String get securityFeature =>
      'Secure platform with encrypted data to protect your family\'s privacy';

// Missing authentication-related implementations
  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signingInWithGoogle => 'Signing in with Google...';

  @override
  String get joinUs => 'Join Us';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signingUpWithGoogle => 'Signing up with Google...';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get signingUpWithApple => 'Signing up with Apple...';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signingInWithApple => 'Signing in with Apple...';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get returnToStart => 'Return to Start';

  @override
  String get getStarted => 'Get Started';

  @override
  String get learnMore => 'Learn More';

  @override
  String get alertaEscolarDescription =>
      'School Alert is a comprehensive platform designed to keep parents informed and connected with their children\'s educational journey.';

  @override
  String get loginErrorMessage => 'Please check your credentials and try again';

  @override
  String get signIn => 'Sign In';

  @override
  String get password => 'Password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signingIn => 'Signing in';

  @override
  String get loginSubtitle => 'Please sign in to your account';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get versionInfo => 'Version 1.0.0';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get guestAccessDescription =>
      'Limited access to public information only';

  @override
  String get guestAccess => 'Guest Access';

  @override
  String get guestAccessWarning =>
      'Guest access provides limited functionality. Sign up for full features.';

  @override
  String get continue_ => 'Continue';

  @override
  String get mustAcceptTerms =>
      'You must accept the terms and conditions to continue';

  @override
  String get signUpErrorMessage =>
      'There was an error creating your account. Please try again.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get iAcceptThe => 'I accept the';

  @override
  String get and => 'and';

  @override
  String get creatingAccount => 'Creating account';

  @override
  String get joinAlertaEscolar => 'Join School Alert';

  @override
  String get signUpSubtitle =>
      'Create your account to get started with School Alert';

  @override
  String get selectUserType => 'Select your user type to continue';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get needHelp => 'Need help?';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get haveSchoolCode => 'Have a school code?';

  @override
  String get schoolCodeDescription =>
      'Enter your school\'s unique code to connect with the institution';

  @override
  String get enterSchoolCode => 'Enter School Code';

  @override
  String get invalidSchoolCode =>
      'Invalid school code. Please verify and try again.';

  @override
  String get enterSchoolCodeHint => 'e.g., SCH123456';

  @override
  String get schoolCodeInfo =>
      'Ask your school administration for the unique school code';

  @override
  String get verifying => 'Verifying';

  @override
  String get verify => 'Verify';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get accountSetupSuccessful => 'Account setup completed successfully!';

  @override
  String get errorSettingUpAccount =>
      'Error setting up account. Please try again.';

  @override
  String get welcomeToAlertaEscolar => 'Welcome to School Alert!';

  @override
  String get pleaseCompleteYourProfile =>
      'Please complete your profile to continue';

  @override
  String get setting => 'Setting';

  @override
  String get continueText => 'Continue';

  @override
  String get thisInformationWillBeUsedForYourProfile =>
      'This information will be used for your profile and to personalize your experience';

  @override
  String get enterCompleteCode => 'Please enter the complete verification code';

  @override
  String get codeVerifiedSuccessfully => 'Code verified successfully!';

  @override
  String get invalidVerificationCode =>
      'Invalid verification code. Please try again.';

  @override
  String get codeResentSuccessfully => 'Verification code resent successfully';

  @override
  String get errorResendingCode => 'Error resending code. Please try again.';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get enterVerificationCode => 'Enter the 6-digit verification code';

  @override
  String get resending => 'Resending';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verificationRequired => 'Verification Required';

  @override
  String get codeSentTo => 'We\'ve sent a verification code to';

  @override
  String get verificationCodeHelpText =>
      'If you don\'t receive the code within a few minutes, check your spam folder or contact support.';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get lightThemeDescription => 'Bright and clean interface';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeDescription =>
      'Dark interface for low light environments';

  @override
  String get apply => 'Apply';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';
  @override
  String studentCountOf(int count) => '$count students';

  @override
  String get arrivedAt => 'arrived at';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  // Attendance status keys
  @override
  String get presentStatusKey => 'Present';

  @override
  String get lateStatusKey => 'Late';

  // Location related
  @override
  String get mainEntrance => 'Main Entrance';

  @override
  String get secondaryEntrance => 'Secondary Entrance';

  @override
  String get lateArrival => 'Late Arrival';

  @override
  String get notification => 'Notification';

  @override
  String get shift => 'Shift';

  @override
  String get access => 'Access';

  @override
  String get both => 'Both';

  @override
  String get justified => 'Justified';

  // Message helpers with student parameter
  @override
  String studentArrivalMessage(String name) => '$name has arrived at school';

  @override
  String studentExitMessage(String name) => '$name has left school';

  @override
  String studentLateMessage(String name) => '$name arrived late to school';

  @override
  String notificationForStudent(String name) => 'Notification for $name';

  @override
  String studentLateArrivalMessage(String name) =>
      '$name arrived late to school';

  // Admin dashboard actions
  @override
  String get mainActions => 'Main Actions';

  @override
  String get manageAnnouncementsAndSchedules =>
      'Manage Announcements and Schedules';

  @override
  String get sendAnnouncement => 'Send Announcement';

  @override
  String get sendNotificationsToStudents => 'Send Notifications to Students';

  @override
  String get viewSchedules => 'View Schedules';

  @override
  String get manageClassSchedules => 'Manage Class Schedules';

  // Time formatting
  @override
  String dateFormat(DateTime date) => '${date.month}/${date.day}/${date.year}';

  @override
  String timeFormat(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

  @override
  String dateFormatFull(DateTime date) =>
      '${monthName(date.month)} ${date.day}, ${date.year}';

  // Time ago helpers
  @override
  String get timeAgoNow => 'just now';

  @override
  String timeAgoMinutes(int minutes) => '$minutes minutes ago';

  @override
  String timeAgoHours(int hours) => '$hours hours ago';

  @override
  String timeAgoDays(int days) => '$days days ago';

  @override
  String minutesAgo(int minutes) => '$minutes minutes ago';

  @override
  String hoursAgo(int hours) => '$hours hours ago';

  // Students directory related
  @override
  String get studentDirectory => 'Student Directory';

  @override
  String studentsCountOf(int count, String filter) => '$count students $filter';

  @override
  String studentCount(int count) => '$count students';

  @override
  String get total => 'total';

  @override
  String get noStudentsFoundWithFilters =>
      'No students found with these filters';

  @override
  String get noRegisteredStudents => 'No registered students';

  @override
  String get studentsWillAppearWhenRegistered =>
      'Students will appear here when registered';

  @override
  String get noDataForFutureDates => 'No data for future dates';

  @override
  String get noScanRecordsForDate => 'No scan records for this date';

  @override
  String get studentsWillAppearWhenScanned =>
      'Students will appear here when scanned';

  // QR scanner related
  @override
  String get tapScanAreaToSimulate => 'Tap scan area to simulate a scan';

  // Student info
  @override
  String get remainingTime => 'Remaining time';

  @override
  String get thirtyDays => '30 days';

  @override
  String get statisticsFor => 'Statistics for';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get editStudentInfoInstructions =>
      'To edit student information, please contact the school administration';

  @override
  String get contactSchoolFeatureComingSoon =>
      'Contact school feature coming soon';

  @override
  String get contactSchool => 'Contact School';

  @override
  String get startScanningDefaultMessage =>
      'Start scanning student QR codes to take attendance';

  @override
  String get scannerConfiguration => 'Scanner Configuration';

  @override
  String get schedules => 'Schedules';

  @override
  String get tolerance => 'Tolerance';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get saveConfiguration => 'Save';

  @override
  String get configurationSavedSuccessfully =>
      'Configuration saved successfully';
  @override
  String openContactInfo(String contactName) =>
      'Open contact info for $contactName';

  @override
  String get educationalLevels => 'Educational Levels';

  @override
  String get manageAndViewYourStudents => 'Manage and view your students';

  @override
  String get manageAndSearchStudents => 'Manage and search students';

  @override
  String get information => 'Information';

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  @override
  String get mixed => 'Mixed';

  @override
  String get preschool => 'Preschool';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get highSchool => 'High School';

  @override
  String get educationalLevel => 'Educational Level';

  @override
  String get institution => 'Institution';

  @override
  String get address => 'Address';

  @override
  String get schoolDescription => 'School Description';

  @override
  String get educationalExcellenceInstitution =>
      'Educational Excellence Institution';

  @override
  String get experienceLabel => 'Experience';

  @override
  String yearsExperience(int years) => '$years years of experience';

  @override
  String get imageUploadSoonAvailable => 'Image upload will be available soon';

  @override
  String errorSaving(String entity) => 'Error saving $entity';
  @override
  String get messageType => 'Message Type';

  @override
  String get requestSpecialPermissionDesc =>
      'Request a special permission for a student';

  @override
  String get communication => 'Announcement';

  @override
  String get sendOfficialCommunicationDesc =>
      'Send official announcement to parents';

  @override
  String get communicationType => 'Announcement Type';

  @override
  String get recipients => 'Recipients';

  @override
  String get individualStudent => 'Individual Student';

  @override
  String get selectSpecificStudent => 'Select a specific student';

  @override
  String get groupClass => 'Group/Class';

  @override
  String get sendToEntireClass => 'Send to entire class';

  @override
  String get entireShift => 'Entire Shift';

  @override
  String get allStudentsInShift => 'All students in shift';

  @override
  String get entireEducationalInstitution => 'Entire educational institution';

  @override
  String get deliveryOptions => 'Delivery Options';

  @override
  String get pushNotification => 'Push Notification';

  @override
  String get sendImmediateNotificationToDevice =>
      'Send immediate notification to device';

  @override
  String get sendCommunication => 'Send Announcement';

  @override
  String get sendNow => 'Send Now';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get sentSuccessfully => 'Sent Successfully';
  @override
  String get emergency => 'Emergency';

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

  // Inside the AppLocalizationsEn class, add all these missing translations:

  @override
  String get calendarExplanationText =>
      'Attendance calendar shows student presence records by day';

  @override
  String get scanningActive => 'Scanning Active';

  @override
  String get readyToScan => 'Ready to Scan';

  @override
  String get stopScanning => 'Stop Scanning';

  @override
  String get excelExportDesc => 'Excel spreadsheet';

  @override
  String get shareReportDesc => 'Share report directly';

  @override
  String get reportGenerationConfirm =>
      'Generate report with selected filters?';

  @override
  String get reportGenerated => 'Report generated successfully';

  @override
  String get share => 'Share';

  @override
  String get attendanceFor => 'Attendance for';

  @override
  String get completedSuccessfully => 'Completed Successfully';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get contactParentsConfirm => 'Contact parents?';

  @override
  String get directoryStats => 'Directory Statistics';

  @override
  String get newThisMonth => 'New This Month';

  @override
  String get searchByNameOrId => 'Search by name or ID';

  @override
  String get searchTip => 'Search tip';

  @override
  String get searchByName => 'Search by name';

  @override
  String get searchById => 'Search by ID';

  @override
  String get searchByGrade => 'Combine with filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get allStatus => 'All Status';

  @override
  String get activeFilters => 'Active Filters';

  @override
  String get tryDifferentFilters => 'Try different filters or search terms';

  @override
  String get registeredOn => 'Registered on';

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
  String get login => 'Login';

  @override
  String get registerWithEmail => 'Register with Email';

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

  // Admin module keys
  @override
  String get adminDashboard => 'Admin Dashboard';
  @override
  String get attendanceControl => 'Attendance Control';
  @override
  String get studentsDirectory => 'Students Directory';
  @override
  String get scheduleManagement => 'Schedule Management';
  @override
  String get schoolSettings => 'School Settings';
  @override
  String get reports => 'Reports';
  @override
  String get scanQR => 'Scan QR';
  @override
  String get attendanceRegistered => 'Attendance Registered';
  @override
  String get createAnnouncement => 'Create Announcement';

  @override
  String get sendToGroup => 'Send to Group';
  @override
  String get sendToStudent => 'Send to Student';
  @override
  String get messageTitle => 'Message Title';
  @override
  String get messageContent => 'Message Content';
  @override
  String get selectGrade => 'Select Grade';
  @override
  String get selectGroup => 'Select Group';
  @override
  String get priority => 'Priority';
  @override
  String get urgent => 'Urgent';
  @override
  String get send => 'Send';
  @override
  String get announcementSent => 'Announcement Sent';
  @override
  String get todayAttendance => 'Today\'s Attendance';
  @override
  String get totalScanned => 'Total Scanned';

  @override
  String get presentStudents => 'Present Students';
  @override
  String get lateStudents => 'Late Students';
  @override
  String get scannedBy => 'Scanned by';
  @override
  String get scanTime => 'Scan Time';
  @override
  String get entryTime => 'Entry Time';
  @override
  String get searchStudents => 'Search Students';
  @override
  String get filterBy => 'Filter by';
  @override
  String get allGrades => 'All Grades';
  @override
  String get allGroups => 'All Groups';
  @override
  String get activeStudents => 'Active Students';
  @override
  String get inactiveStudents => 'Inactive Students';
  @override
  String get studentsFound => 'Students Found';
  @override
  String get noStudentsFound => 'No Students Found';
  @override
  String get studentProfile => 'Student Profile';
  @override
  String get familyContacts => 'Family Contacts';

  @override
  String get attendanceHistory => 'Attendance History';
  @override
  String get academicRecord => 'Academic Record';
  @override
  String get contactParents => 'Contact Parents';
  @override
  String get editStudent => 'Edit Student';
  @override
  String get turn => 'Turn';
  @override
  String get morningShift => 'Morning Shift';
  @override
  String get afternoonShift => 'Afternoon Shift';
  @override
  String get activated => 'Activated';
  @override
  String get deactivated => 'Deactivated';
  @override
  String get timeRemaining => 'Time Remaining';
  @override
  String get days => 'Days';
  @override
  String get entryTolerance => 'Entry Tolerance';
  @override
  String get lateTolerance => 'Late Tolerance';
  @override
  String get exitTime => 'Exit Time';
  @override
  String get configureSchedules => 'Configure Schedules';
  @override
  String get schoolInfo => 'School Information';
  @override
  String get schoolName => 'School Name';
  @override
  String get schoolAddress => 'School Address';
  @override
  String get schoolPhone => 'Phone';
  @override
  String get schoolEmail => 'School';
  @override
  String get principalName => 'Principal Name';
  @override
  String get schoolLogo => 'School Logo';
  @override
  String get schoolColors => 'School Colors';
  @override
  String get primaryColor => 'Primary Color';
  @override
  String get secondaryColor => 'Secondary Color';
  @override
  String get accentColor => 'Accent Color';

  @override
  String get updateSettings => 'Update Settings';
  @override
  String get settingsUpdated => 'Settings Updated';
  @override
  String get selectDateRange => 'Select Date Range';
  @override
  String get startDate => 'Start Date';
  @override
  String get endDate => 'End Date';
  @override
  String get generateReport => 'Generate Report';
  @override
  String get exportReport => 'Export Report';
  @override
  String get attendanceRate => 'Attendance Rate';
  @override
  String get punctualityRate => 'Punctuality Rate';
  @override
  String get absenceRate => 'Absence Rate';
  @override
  String get totalDays => 'Total Days';
  @override
  String get presentDays => 'Present Days';
  @override
  String get lateDays => 'Late Days';
  @override
  String get absentDays => 'Absent Days';
  @override
  String get monthlyReport => 'Monthly Report';
  @override
  String get weeklyReport => 'Weekly Report';
  @override
  String get dailyReport => 'Daily Report';
  @override
  String get byGrade => 'By Grade';
  @override
  String get byGroup => 'By Group';
  @override
  String get byStudent => 'By Student';
  @override
  String get attendanceCalendar => 'Attendance Calendar';
  @override
  String get viewDetails => 'View Details';
  @override
  String get scannedStudents => 'Scanned Students';

  // Inside the AppLocalizationsEn class, add all these missing translations:

  @override
  String get timeSettings => 'Time Settings';

  @override
  String get toleranceSettings => 'Tolerance Settings';

  @override
  String get minutes => 'Minutes';

  @override
  String get editingScheduleFor => 'Editing schedule for';

  @override
  String get emergencyPhone => 'Emergency Phone';

  @override
  String get website => 'Website';

  @override
  String get socialMedia => 'Social Media';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get saving => 'Saving';

  @override
  String get schoolBranding => 'School Branding';

  @override
  String get schoolCode => 'Code';

  @override
  String get foundedYear => 'Founded';

  @override
  String get description => 'Description';

  @override
  String get changeLogo => 'Change Logo';

  @override
  String get uploadLogo => 'Upload Logo';

  @override
  String get logoUploaded => 'Logo Uploaded';

  @override
  String get noLogoUploaded => 'No Logo Uploaded';

  @override
  String get preview => 'Preview';

  @override
  String get selectReportType => 'Select Report Type';

  @override
  String get punctualityReport => 'Punctuality Report';

  @override
  String get absenceReport => 'Absence Report';

  @override
  String get summaryReport => 'Summary Report';

  @override
  String get reportFilters => 'Report Filters';

  @override
  String get reportPeriod => 'Report Period';

  @override
  String get customPeriod => 'Custom Period';

  @override
  String get exportAs => 'Export as';

  @override
  String get exportConfirm => 'The report will be exported in format';

  @override
  String get export => 'Export';

  @override
  String get exporting => 'Exporting';

  @override
  String get generating => 'Generating';

  @override
  String get exportedSuccessfully => 'Exported successfully in format';

  @override
  String get attendanceReportDesc => 'Detailed attendance report by period';

  @override
  String get punctualityReportDesc => 'Analysis of tardiness and punctuality';

  @override
  String get absenceReportDesc => 'Statistics of school absenteeism';

  @override
  String get summaryReportDesc => 'Overview of all metrics';

  @override
  String get adminActions => 'Admin Actions';

  @override
  String get primaryActions => 'Primary Actions';

  @override
  String get communicationActions => 'Announcement Actions';

  @override
  String get administrativeActions => 'Administrative Actions';

  @override
  String get emergencyActions => 'Emergency Actions';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get addNote => 'Add Note';

  @override
  String get scheduleCall => 'Schedule Call';

  @override
  String get printProfile => 'Print Profile';

  @override
  String get contact => 'Contact';

  @override
  String get schedule => 'Schedule';

  @override
  String get generate => 'Generate';

  @override
  String get print => 'Print';

  @override
  String get emergencyContactInitiated => 'Emergency Contact Initiated';

  @override
  String get sendMessageConfirm => 'Send message to parents?';

  @override
  String get sendEmailConfirm => 'Send email to parents?';

  @override
  String get addNoteConfirm => 'Add note to student record?';

  @override
  String get scheduleCallConfirm => 'Schedule call with parents?';

  @override
  String get generateReportConfirm => 'Generate student report?';

  @override
  String get printProfileConfirm => 'Print student profile?';

  @override
  String get emergencyContactConfirm => 'Initiate emergency contact protocol?';

  @override
  String get editStudentConfirm => 'Edit student information?';

  @override
  String get grades => 'Grades';

  @override
  String get groups => 'Groups';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get viewAllRecords => 'View All Records';

  @override
  String get lastStudentScanned => 'Last Student Scanned';

  @override
  String get unknown => 'Unknown';

  @override
  String get now => 'Now';

  @override
  String get startScanningToSeeRecords => 'Start scanning to see records';

  @override
  String get noStudentsScanned => 'No students scanned';

  @override
  String get noAttendanceThisDate => 'No attendance for this date';

  @override
  String get totalAnnouncementsSent => 'Total announcements sent';

  @override
  String get read => 'Read';

  @override
  String get delivered => 'Delivered';

  @override
  String get pending => 'Pending';

  @override
  String get failed => 'Failed';

  @override
  String get noAnnouncementsSent => 'No announcements sent';

  @override
  String get createFirstAnnouncement => 'Create your first announcement';

  @override
  String get contacts => 'Contacts';

  @override
  String get primaryContact => 'Primary Contact';

  @override
  String get occupation => 'Occupation';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get recentRecords => 'Recent Records';

  @override
  String get pdfExportDesc => 'PDF document for printing';

  @override
  String get imageExportDesc => 'Image for presentations';

  // Additional missing keys for admin components
  @override
  String get selectRecipient => 'Select Recipient';
  @override
  String get enterMessageTitle => 'Enter message title';
  @override
  String get titleRequired => 'Title is required';
  @override
  String get enterMessageContent => 'Enter message content';
  @override
  String get contentRequired => 'Content is required';
  @override
  String get sending => 'Sending';

  @override
  String get totalStudents => 'Total Students';
  @override
  String get absentStudents => 'Absent Students';
  @override
  String get calendarLegend => 'Calendar Legend';
  @override
  String get fullAttendance => 'Full Attendance';
  @override
  String get partialAttendance => 'Partial Attendance';
  @override
  String get lowAttendance => 'Low Attendance';
  @override
  String get noClasses => 'No Classes';

  // Admin schedule management
  @override
  String get filterByDay => 'Filter by Day';
  @override
  String get all => 'All';
  @override
  String get schedulesByGroup => 'Schedules by Group';
  @override
  String get selectClass => 'Select Class';
  @override
  String get chooseClassForNotification => 'Choose class for notification';
  @override
  String get classSelected => 'Class Selected';
  @override
  String get tapToChooseClass => 'Tap to choose class';
  @override
  String get selectShift => 'Select Shift';
  @override
  String get selectShiftToSend => 'Select Shift to Send';
  @override
  String get chooseShiftToReceiveNotification =>
      'Choose shift to receive notification';
  @override
  String get shiftSelected => 'Shift Selected';
  @override
  String get tapToChooseShift => 'Tap to choose shift';
  @override
  String get classes => 'Classes';
  @override
  String get morning => 'Morning';
  @override
  String get afternoon => 'Afternoon';
  @override
  String get entry => 'Entry';
  @override
  String get exit => 'Exit';
  @override
  String get after => 'After';
  @override
  String get tapToChange => 'Tap to Change';
  @override
  String get configureShiftSchedules => 'Configure Shift Schedules';
  @override
  String get setEntryExitHoursForShifts => 'Set Entry/Exit Hours for Shifts';
  @override
  String get ofTolerance => 'of Tolerance';
  @override
  String get adjustTolerance => 'Adjust Tolerance';
  @override
  String get min => 'Min';
  @override
  String get quickSelection => 'Quick Selection';
  @override
  String get toleranceForLateArrivals => 'Tolerance for Late Arrivals';
  @override
  String get needScheduleChanges => 'Need Schedule Changes?';
  @override
  String get scheduleChangesDescription => 'Schedule changes description';

  // Admin notifications
  @override
  String get informative => 'Informative';
  @override
  String get fieldTrip => 'Field Trip';
  @override
  String get paymentReminder => 'Payment Reminder';
  @override
  String get citation => 'Citation';
  @override
  String get celebration => 'Celebration';
  @override
  String get classSuspension => 'Class Suspension';
  @override
  String get scheduleChange => 'Schedule Change';
  @override
  String get critical => 'Critical';
  @override
  String get exampleCommunicationTitle => 'Example Announcement Title';
  @override
  String get examplePermissionTitle => 'Example Permission Title';
  @override
  String get message => 'Message';
  @override
  String get communicationContentHint => 'Enter announcement content here...';
  @override
  String get messageContentHint => 'Enter message content here...';
  @override
  String get communicationTip => 'Announcement Tip';
  @override
  String get messageTip => 'Message Tip';
  @override
  String get selectStudentFromDirectory => 'Select Student from Directory';
  @override
  String get searchInDirectory => 'Search in Directory';
  @override
  String get navigateToStudentDirectory => 'Navigate to Student Directory';

  // Admin QR and notifications
  @override
  String get scanQRToRegisterAttendance => 'Scan QR to Register Attendance';
  @override
  String get sendNotification => 'Send Notification';
  @override
  String get scanning => 'Scanning';

  // Admin school settings
  @override
  String get selectColor => 'Select Color';
  @override
  String get basicInformation => 'Basic Information';
  @override
  String get principal => 'Principal';
  @override
  String get institutionalConfiguration => 'Institutional Configuration';
  @override
  String get schoolType => 'School Type';
  @override
  String get educationLevels => 'Education Levels';
  @override
  String get selectEducationLevels => 'Select Education Levels';
  @override
  String get selectAtLeastOneLevel => 'Select at least one level';
  @override
  String get aboutSchool => 'About School';

  // Admin student records
  @override
  String get noRecordsFound => 'No Records Found';
  @override
  String get tryAdjustingFilters => 'Try adjusting filters';
  @override
  String get detailedRecords => 'Detailed Records';
  @override
  String get searchStudent => 'Search Student';

  @override
  String get noFamilyContactsRegistered => 'No family contacts registered';

  @override
  String get noName => 'No name';

  @override
  String get noRelationship => 'No relationship specified';

  @override
  String get date => 'Date';

  @override
  String get title => 'Title';
}

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs() : super('es');

  @override
  String get noFamilyContactsRegistered =>
      'No hay contactos familiares registrados';

  @override
  String get noName => 'Sin nombre';

  @override
  String get noRelationship => 'Sin relación especificada';

  @override
  String get date => 'Fecha';

  @override
  String get title => 'Título';

  @override
  String get scanningActive => 'Escaneo activo';
  @override
  String get pleaseCreateAccount => 'Por favor crea una cuenta para continuar';

  @override
  String get readyToScan => 'Listo para escanear';

  @override
  String get stopScanning => 'Detener escaneo';

  @override
  String get excelExportDesc => 'Hoja de cálculo Excel';

  @override
  String get appleNotAvailable =>
      'Inicio de sesión con Apple no está disponible en este dispositivo';

  // Time related
  @override
  String get timeSeparator => ':';
  @override
  String get am => 'AM';
  @override
  String get pm => 'PM';
  @override
  String get tapToOpenCamera => 'Toca para abrir la cámara';

  @override
  String get credentialSavedSuccessfully => 'Credencial guardada correctamente';

  @override
  String get errorSavingCredential => 'Error al guardar la credencial';

  @override
  String get sessionExpiredOrNoUser =>
      'Tu sesión ha expirado o no hay un usuario autenticado. Inicia sesión nuevamente.';

  @override
  String get signInCanceled => 'Proceso de inicio de sesión cancelado';

  @override
  String get registerCanceled => 'Proceso de registro cancelado';

  @override
  String get refresh => 'Actualizar';

// QR Scanner
  @override
  String get qrScannerPointCamera =>
      'Apunta la cámara al código QR del estudiante';
  @override
  String get qrScannerTitle => 'Escanear Código QR';
  @override
  String get qrScannerAutomatic =>
      'Posiciona el código QR dentro del marco para escanearlo automáticamente';
  @override
  String get scanAnother => 'Escanear Otro';
  @override
  String get cameraScanner => 'Escáner de Cámara';

// Student Records
  @override
  String attendanceRecordOf(String name) => 'Registro de asistencia de $name';
  @override
  String get delayedEntry => 'Entrada Tardía';
  @override
  String get lastFiveRecords => 'Últimos 5 Registros';
  @override
  String get entryRecords => 'Registros de Entrada';
  @override
  String get delayedEntries => 'Entradas Tardías';
  @override
  String get exitRecords => 'Registros de Salida';

// Class Schedule
  @override
  String durationInMinutes(int minutes) => '$minutes minutos';
  @override
  String get classroom => 'Aula';
  @override
  String get classDetails => 'Detalles de la Clase';

// Student Information
  @override
  String get defaultStudentInitial => 'E';
  @override
  String studentGradeAndGroup(String grade, String group) =>
      'Grado $grade Grupo $group';
  @override
  String get linkedTutor => 'Tutor Vinculado';
  @override
  String get linkedTutors => 'Tutores Vinculados';
  @override
  String get informationNotAvailable => 'Información no disponible';
  @override
  String get noTimeLimit => 'Sin límite de tiempo';
  @override
  String get expired => 'Expirado';
  @override
  String get oneDayRemaining => 'Un día restante';
  @override
  String daysRemaining(int days) => '$days días restantes';
  @override
  String get oneHourRemaining => 'Una hora restante';
  @override
  String hoursRemaining(int hours) => '$hours horas restantes';
  @override
  String get oneMinuteRemaining => 'Un minuto restante';
  @override
  String minutesRemaining(int minutes) => '$minutes minutos restantes';
  @override
  String get lessThanOneMinuteRemaining => 'Menos de un minuto restante';

// School Subjects
  @override
  String get break_ => 'Receso';
  @override
  String get mathematics => 'Matemáticas';
  @override
  String get naturalSciences => 'Ciencias Naturales';
  @override
  String get history => 'Historia';
  @override
  String get physicalEducation => 'Educación Física';
  @override
  String get art => 'Arte';

// Scanner Configuration
  @override
  String get automaticEntry => 'Entrada Automática';
  @override
  String get automaticExit => 'Salida Automática';
  @override
  String get unauthenticatedUser => 'Usuario no Autenticado';
  @override
  String get schoolNotIdentified => 'Escuela no identificada';
  @override
  String errorLoadingConfiguration(String error) =>
      'Error al cargar la configuración: $error';

// Notifications and Messages
  @override
  String get reviewMessage => 'Revisar Mensaje';
  @override
  String get officialCommunication => 'Comunicación Oficial';
  @override
  String get reviewCarefullyBeforeContinuing =>
      'Por favor revisa cuidadosamente antes de continuar';
  @override
  String get communicationDetails => 'Detalles de la Comunicación';
  @override
  String get type => 'Tipo';

// Error Messages
  @override
  String internalError(String error) => 'Error Interno: $error';
  @override
  String get couldNotGetUserSchool =>
      'No se pudo obtener la escuela del usuario';
  @override
  String get errorLoadingStats => 'Error al cargar estadísticas';
  @override
  String get errorLoadingData => 'Error al cargar datos';

// Filters and Headers
  @override
  String get filters => 'Filtros';
  @override
  String get attendanceDate => 'Fecha de Asistencia';

  @override
  String get shareReportDesc => 'Compartir informe directamente';

  @override
  String get loadingFamilyContacts => 'Cargando contactos familiares...';

  @override
  String get loadingNotifications => 'Cargando notificaciones...';

  @override
  String get emailInvalid => 'Dirección de correo inválida';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String get qrScannerPlaceholder => 'Apunta la cámara al código QR';

  @override
  String get qrScannerInstructions =>
      'Alinea el código QR dentro del marco para escanear';

  @override
  String get qrScannerBottomInstructions =>
      'Asegúrate de que el código QR esté bien iluminado y visible';

  // Student validation strings - Spanish
  @override
  String get validatingCode => 'Validando código...';

  @override
  String get validateCode => 'Validar Código';

  @override
  String get invalidStudentCode => 'Código de estudiante inválido';

  @override
  String get errorValidatingCode => 'Error al validar código';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get studentRegisteredSuccessfully =>
      'Estudiante registrado exitosamente';

  @override
  String get errorRegisteringStudent => 'Error al registrar estudiante';

  // Student confirmation dialog strings - Spanish
  @override
  String get confirmStudentRegistration => 'Confirmar Registro de Estudiante';

  @override
  String get studentToRegister => 'Estudiante a Registrar';

  @override
  String get gradeGroup => 'Grado/Grupo';

  @override
  String get confirmRegistrationMessage =>
      '¿Estás seguro de que quieres registrar este estudiante?';

  @override
  String get confirmRegistration => 'Confirmar Registro';

  @override
  String get noChangesDetected => 'No se detectaron cambios';

  @override
  String get loadingUserData => 'Cargando datos del usuario...';
  @override
  String get updatingPersonalInfo => 'Actualizando información personal...';

  @override
  String get editContact => 'Editar Contacto';

  @override
  String get name => 'Nombre';

  @override
  String get enterContactName => 'Ingresa nombre del contacto';

  @override
  String get enterPhoneNumber => 'Ingresa número telefónico';

  @override
  String get enterEmail => 'Ingresa dirección de correo';

  @override
  String get contactUpdatedSuccessfully => 'Contacto actualizado exitosamente';

  @override
  String get errorUpdatingContact => 'Error al actualizar contacto';

  @override
  String get error => 'Error';

  @override
  String get loadingSchoolInformation =>
      'Cargando información de la escuela...';

  @override
  String get errorFetchingSchool =>
      'Error al obtener la información de la escuela';

  @override
  String get errorLoadingSchool => 'Error al cargar los datos de la escuela';

  @override
  String get updatingSchoolInformation =>
      'Actualizando información de la escuela...';

  @override
  String get errorUpdatingSchool =>
      'Error al actualizar la información de la escuela';

  @override
  String get noAssociatedSchool => 'No se encontró escuela asociada';

  @override
  String get errorLoadingSchoolInfo =>
      'Error al cargar la información de la escuela';

  @override
  String get requiredFields => 'Campos Obligatorios';

  @override
  String get pleaseCompleteFields =>
      'Por favor completa todos los campos obligatorios';

  @override
  String get couldNotGetSchoolInfo =>
      'No se pudo obtener la información de la escuela';

  @override
  String get unknownError => 'Ocurrió un error desconocido';

  @override
  String get errorSavingChanges => 'Error al guardar los cambios';

  @override
  String get associatedSchool => 'Escuela Asociada';
  @override
  String get accountType => 'Tipo de Cuenta';
  @override
  String get unverified => 'No Verificado';
  @override
  String get administrativeRole => 'Rol Administrativo';
  @override
  String get todayAt => 'Hoy a las';
  @override
  String get yesterdayAt => 'Ayer a las';
  @override
  String get administratorAccount => 'Cuenta de Administrador';
  @override
  String get adminAccountInformation =>
      'Tienes privilegios de administrador. Puedes acceder y gestionar información de la escuela, estudiantes y configuraciones de seguridad.';

  @override
  String get neverConnected => 'Nunca conectado';
  @override
  String get school => 'Escuela';
  @override
  String get director => 'Director';
  @override
  String get subdirector => 'Subdirector';
  @override
  String get secretary => 'Secretario';
  @override
  String get securityStaff => 'Personal de Seguridad';
  @override
  String get teacher => 'Maestro';
  @override
  String get administrative => 'Administrativo';
  @override
  String get administrativo => 'Administrativo';
  @override
  String get administrator => 'Administrador';
  @override
  String get parent => 'Padre/Madre';
  @override
  String get student => 'Estudiante';

  @override
  String get verifyingCode => 'Verificando código...';

  @override
  String get resendingCode => 'Reenviando código...';

  @override
  String get registering => 'Registrando...';

  @override
  String get loading => 'Cargando...';

  // Implementaciones de los nuevos getters en español
  @override
  String get updatingContact => 'Actualizando contacto...';

  @override
  String get deletingContact => 'Eliminando contacto...';

  @override
  String get savingContact => 'Guardando contacto...';

  @override
  String get settingUpAccount => 'Configurando cuenta...';

  @override
  String get myProfile => 'Mi Perfil';
  @override
  String get manageYourAccount => 'Administra tu cuenta';
  @override
  String get user => 'Usuario';
  @override
  String get parentRole => 'Padre/Madre';
  @override
  String get fatherRole => 'Padre';
  @override
  String get motherRole => 'Madre';
  @override
  String get tutorRole => 'Tutor';
  @override
  String get relativeRole => 'Familiar';
  @override
  String get adminRole => 'Administrador';

  // Add implementations to AppLocalizationsEs class:

  @override
  String get verificationSuccessful => 'Verificación exitosa';

  @override
  String get completeYourProfile => 'Por favor completa tu perfil';

  @override
  String get loginSuccessful => 'Inicio de sesión exitoso';

  @override
  String get appleSignInError => 'Hubo un problema al iniciar sesión con Apple';

  @override
  String get googleSignInError =>
      'Hubo un problema al iniciar sesión con Google';

  @override
  String get accountSetupSuccessfully =>
      'Configuración de cuenta completada exitosamente';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get logoutSuccessful => 'Cierre de sesión exitoso';

  @override
  String get logoutError => 'Hubo un problema al cerrar sesión';

  @override
  String get relationshipType => 'Tipo de Relación';

  @override
  String get selectYourRelationshipWithStudent =>
      'Selecciona tu relación con el estudiante';

  @override
  String get tutor => 'Tutor';

  @override
  String get relative => 'Familiar';

  @override
  String get emailAlreadyExists =>
      'Esta dirección de correo ya está registrada';

  @override
  String get reportGenerationConfirm =>
      '¿Generar informe con los filtros seleccionados?';

  @override
  String get reportGenerated => 'Informe generado exitosamente';

  @override
  String get share => 'Compartir';

  @override
  String get attendanceFor => 'Asistencia para';

  @override
  String get completedSuccessfully => 'Completado exitosamente';

  @override
  String get contactInfo => 'Información de contacto';

  @override
  String get contactParentsConfirm => '¿Contactar a los padres?';

  @override
  String get directoryStats => 'Estadísticas del directorio';

  @override
  String get newThisMonth => 'Nuevos este mes';

  @override
  String get searchByNameOrId => 'Buscar por nombre o ID';

  @override
  String get verification => 'Verificación';

  @override
  String get searchTip => 'Consejo de búsqueda';

  @override
  String get searchByName => 'Buscar por nombre';

  @override
  String get searchById => 'Buscar por ID';

  @override
  String get signUpEmailRegistered => 'Este correo ya está registrado';

  @override
  String get alertaEscolar => 'Alerta Escolar';

  @override
  String get introWelcomeMessage =>
      'Mantente conectado con las actividades escolares de tu hijo';

  @override
  String get introFooterText =>
      'Descubre todas las funciones que te ayudarán a mantenerte informado sobre la educación de tu hijo';

  @override
  String get qrAttendanceFeature =>
      'Seguimiento de asistencia con código QR para registros rápidos y precisos';

  @override
  String get realTimeNotificationsFeature =>
      'Notificaciones instantáneas para llegadas, salidas y anuncios importantes';

  @override
  String get securityFeature =>
      'Plataforma segura con datos encriptados para proteger la privacidad de tu familia';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get learnMore => 'Saber Más';

  @override
  String get alertaEscolarDescription =>
      'Alerta Escolar es una plataforma integral diseñada para mantener a los padres informados y conectados con el viaje educativo de sus hijos.';

  @override
  String get loginErrorMessage =>
      'Por favor verifica tus credenciales e intenta nuevamente';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signingIn => 'Iniciando sesión';

  @override
  String get loginSubtitle => 'Por favor inicia sesión en tu cuenta';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get signUp => 'Registrarse';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get versionInfo => 'Versión 1.0.0';

  @override
  String get continueAsGuest => 'Continuar como Invitado';

  @override
  String get guestAccessDescription =>
      'Acceso limitado solo a información pública';

  @override
  String get guestAccess => 'Acceso de Invitado';

  @override
  String get guestAccessWarning =>
      'El acceso de invitado proporciona funcionalidad limitada. Regístrate para obtener todas las funciones.';

// Missing authentication-related implementations
  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get signingInWithGoogle => 'Iniciando sesión con Google...';

  @override
  String get joinUs => 'Únete a nosotros';

  @override
  String get signUpWithGoogle => 'Registrarse con Google';

  @override
  String get signingUpWithGoogle => 'Registrándose con Google...';

  @override
  String get signUpWithApple => 'Registrarse con Apple';

  @override
  String get signingUpWithApple => 'Registrándose con Apple...';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get signingInWithApple => 'Iniciando sesión con Apple...';

  @override
  String get changeEmail => 'Cambiar Email';

  @override
  String get returnToStart => 'Volver al inicio';

  @override
  String get continue_ => 'Continuar';

  @override
  String get mustAcceptTerms =>
      'Debes aceptar los términos y condiciones para continuar';

  @override
  String get signUpErrorMessage =>
      'Hubo un error al crear tu cuenta. Por favor intenta nuevamente.';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get iAcceptThe => 'Acepto los';

  @override
  String get and => 'y';

  @override
  String get creatingAccount => 'Creando cuenta';

  @override
  String get joinAlertaEscolar => 'Únete a Alerta Escolar';

  @override
  String get signUpSubtitle =>
      'Crea tu cuenta para comenzar con Alerta Escolar';

  @override
  String get selectUserType => 'Selecciona tu tipo de usuario para continuar';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get needHelp => '¿Necesitas ayuda?';

  @override
  String get contactSupport => 'Contactar Soporte';

  @override
  String get haveSchoolCode => '¿Tienes un código escolar?';

  @override
  String get schoolCodeDescription =>
      'Ingresa el código único de tu escuela para conectarte con la institución';

  @override
  String get enterSchoolCode => 'Ingresar Código Escolar';

  @override
  String get invalidSchoolCode =>
      'Código escolar inválido. Por favor verifica e intenta nuevamente.';

  @override
  String get enterSchoolCodeHint => 'ej., ESC123456';

  @override
  String get schoolCodeInfo =>
      'Solicita a la administración de tu escuela el código escolar único';

  @override
  String get verifying => 'Verificando';

  @override
  String get verify => 'Verificar';

  @override
  String get pleaseEnterFullName => 'Por favor ingresa tu nombre completo';

  @override
  String get accountSetupSuccessful =>
      '¡Configuración de cuenta completada exitosamente!';

  @override
  String get errorSettingUpAccount =>
      'Error al configurar la cuenta. Por favor intenta nuevamente.';

  @override
  String get welcomeToAlertaEscolar => '¡Bienvenido a Alerta Escolar!';

  @override
  String get pleaseCompleteYourProfile =>
      'Por favor completa tu perfil para continuar';

  @override
  String get setting => 'Configurando';

  @override
  String get continueText => 'Continuar';

  @override
  String get thisInformationWillBeUsedForYourProfile =>
      'Esta información será utilizada para tu perfil y para personalizar tu experiencia';

  @override
  String get enterCompleteCode => 'Por favor ingresa  verificación completo';

  @override
  String get codeVerifiedSuccessfully => '¡Código verificado exitosamente!';

  @override
  String get invalidVerificationCode =>
      'Código de verificación inválido. Por favor intenta nuevamente.';

  @override
  String get codeResentSuccessfully =>
      'Código de verificación reenviado exitosamente';

  @override
  String get errorResendingCode =>
      'Error al reenviar el código. Por favor intenta nuevamente.';

  @override
  String get verifyCode => 'Verificar Código';

  @override
  String get enterVerificationCode =>
      'Ingresa el código de verificación de 6 dígitos';

  @override
  String get resending => 'Reenviando';

  @override
  String get resendCode => 'Reenviar Código';

  @override
  String get verificationRequired => 'Verificación Requerida';

  @override
  String get codeSentTo => 'Hemos enviado un código de verificación a';

  @override
  String get verificationCodeHelpText =>
      'Si no recibes el código en unos minutos, revisa tu carpeta de spam o contacta al soporte.';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get lightThemeDescription => 'Interfaz brillante y limpia';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get darkThemeDescription =>
      'Interfaz oscura para entornos de poca luz';

  @override
  String get apply => 'Aplicar';

  @override
  String get searchByGrade => 'Combinar con filtros';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get allStatus => 'Todos los estados';

  @override
  String get activeFilters => 'Filtros activos';

  @override
  String get tryDifferentFilters =>
      'Intenta usar diferentes filtros o términos de búsqueda';

  @override
  String get registeredOn => 'Registrado el';

  @override
  String get selectTime => 'Seleccionar Hora';

  @override
  String get hours => 'Horas';

  @override
  String get ok => 'Aceptar';
  @override
  String get noSchedulesAvailable => 'No hay horarios disponibles';
  @override
  String get scannerConfiguration => 'Configuración del Escáner';
  @override
  String noClassesForDay(String day) => 'No hay clases para $day';

  @override
  String get noSchedulesConfiguredForGroup =>
      'No hay horarios configurados para este grupo';

  @override
  String get noClassesScheduledForThisDay =>
      'No hay clases programadas para este día';
  @override
  String get schedules => 'Horarios';

  @override
  String get tolerance => 'Tolerancia';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get magicLinkSent =>
      '¡Enlace mágico enviado! Revisa tu correo para continuar.';

  @override
  String get saveConfiguration => 'Guardar';

  @override
  String get configurationSavedSuccessfully =>
      'Configuración guardada correctamente';
  @override
  String openContactInfo(String contactName) =>
      'Abrir información de contacto de $contactName';

  @override
  String get educationalLevels => 'Niveles Educativos';

  @override
  String get manageAndViewYourStudents =>
      'Administra y visualiza tus estudiantes';
  @override
  String get allStatuses => 'Todos los Estados';

  @override
  String get searchByDateStaffOrLocation =>
      'Buscar por fecha, personal o ubicación';

  @override
  String get searchFilters => 'Filtros de Búsqueda';

  @override
  String get id => 'ID';

  @override
  String get startTime => 'Hora de Inicio';

  @override
  String get endTime => 'Hora de Fin';

  @override
  String studentCountOf(int count) => '$count estudiantes';

  @override
  String get arrivedAt => 'llegó a las';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mié';

  @override
  String get thursdayShort => 'Jue';

  @override
  String get fridayShort => 'Vie';

  @override
  String get saturdayShort => 'Sáb';

  @override
  String get sundayShort => 'Dom';

  // Attendance status keys
  @override
  String get presentStatusKey => 'Presente';

  @override
  String get lateStatusKey => 'Tarde';

  // Location related
  @override
  String get mainEntrance => 'Entrada Principal';

  @override
  String get secondaryEntrance => 'Entrada Secundaria';

  @override
  String get lateArrival => 'Llegada Tarde';

  @override
  String get notification => 'Notificación';

  @override
  String get shift => 'Turno';

  @override
  String get access => 'Acceso';

  @override
  String get both => 'Ambos';

  @override
  String get justified => 'Justificado';

  // Message helpers with student parameter
  @override
  String studentArrivalMessage(String name) => '$name ha llegado a la escuela';

  @override
  String studentExitMessage(String name) => '$name ha salido de la escuela';

  @override
  String studentLateMessage(String name) => '$name llegó tarde a la escuela';

  @override
  String notificationForStudent(String name) => 'Notificación para $name';

  @override
  String studentLateArrivalMessage(String name) =>
      '$name llegó tarde a la escuela';

  // Admin dashboard actions
  @override
  String get mainActions => 'Acciones Principales';

  @override
  String get manageAnnouncementsAndSchedules => 'Gestionar Anuncios y Horarios';

  @override
  String get sendAnnouncement => 'Enviar Anuncio';

  @override
  String get sendNotificationsToStudents =>
      'Enviar Notificaciones a Estudiantes';

  @override
  String get viewSchedules => 'Ver Horarios';

  @override
  String get manageClassSchedules => 'Gestionar Horarios de Clases';

  // Time formatting
  @override
  String dateFormat(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  String timeFormat(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

  @override
  String dateFormatFull(DateTime date) =>
      '${date.day} de ${monthName(date.month)} de ${date.year}';

  // Time ago helpers
  @override
  String get timeAgoNow => 'ahora mismo';

  @override
  String timeAgoMinutes(int minutes) => 'hace $minutes minutos';

  @override
  String timeAgoHours(int hours) => 'hace $hours horas';

  @override
  String timeAgoDays(int days) => 'hace $days días';

  @override
  String minutesAgo(int minutes) => 'hace $minutes minutos';

  @override
  String hoursAgo(int hours) => 'hace $hours horas';

  // Students directory related
  @override
  String get studentDirectory => 'Directorio de Estudiantes';

  @override
  String studentsCountOf(int count, String filter) =>
      '$count estudiantes $filter';

  @override
  String studentCount(int count) => '$count estudiantes';

  @override
  String get total => 'total';

  @override
  String get noStudentsFoundWithFilters =>
      'No se encontraron estudiantes con estos filtros';

  @override
  String get noRegisteredStudents => 'No hay estudiantes registrados';

  @override
  String get studentsWillAppearWhenRegistered =>
      'Los estudiantes aparecerán aquí cuando estén registrados';

  @override
  String get noDataForFutureDates => 'No hay datos para fechas futuras';

  @override
  String get noScanRecordsForDate =>
      'No hay registros de escaneo para esta fecha';

  @override
  String get studentsWillAppearWhenScanned =>
      'Los estudiantes aparecerán aquí cuando se escaneen';

  // QR scanner related
  @override
  String get tapScanAreaToSimulate =>
      'Toca el área de escaneo para simular un escaneo';

  // Student info
  @override
  String get remainingTime => 'Tiempo restante';

  @override
  String get thirtyDays => '30 días';

  @override
  String get statisticsFor => 'Estadísticas para';

  @override
  String get daysOfWeek => 'Días de la semana';

  @override
  String get editStudentInfoInstructions =>
      'Para editar la información del estudiante, contacte a la administración de la escuela';

  @override
  String get contactSchoolFeatureComingSoon =>
      'Función de contactar escuela próximamente';

  @override
  String get contactSchool => 'Contactar Escuela';

  @override
  String get startScanningDefaultMessage =>
      'Comienza a escanear códigos QR de estudiantes para tomar asistencia';

  @override
  String get manageAndSearchStudents => 'Administra y busca estudiantes';

  @override
  String get information => 'Información';

  @override
  String get public => 'Público';

  @override
  String get private => 'Privado';

  @override
  String get mixed => 'Mixto';

  @override
  String get preschool => 'Preescolar';

  @override
  String get primary => 'Primaria';

  @override
  String get secondary => 'Secundaria';

  @override
  String get highSchool => 'Preparatoria';

  @override
  String get educationalLevel => 'Nivel Educativo';

  @override
  String get institution => 'Institución';

  @override
  String get address => 'Dirección';

  @override
  String get schoolDescription => 'Descripción de la Escuela';

  @override
  String get educationalExcellenceInstitution =>
      'Institución de Excelencia Educativa';

  @override
  String get experienceLabel => 'Experiencia';

  @override
  String yearsExperience(int years) => '$years años de experiencia';

  @override
  String get imageUploadSoonAvailable =>
      'La carga de imágenes estará disponible próximamente';
  @override
  String get messageType => 'Tipo de Mensaje';

  @override
  String get requestSpecialPermissionDesc =>
      'Solicitar un permiso especial para un estudiante';

  @override
  String get communication => 'Comunicado';

  @override
  String get sendOfficialCommunicationDesc =>
      'Enviar comunicado oficial a los padres';

  @override
  String get communicationType => 'Tipo de Comunicado';

  @override
  String get recipients => 'Destinatarios';

  @override
  String get individualStudent => 'Estudiante Individual';

  @override
  String get selectSpecificStudent => 'Seleccionar un estudiante específico';

  @override
  String get groupClass => 'Grupo/Clase';

  @override
  String get sendToEntireClass => 'Enviar a toda la clase';

  @override
  String get entireShift => 'Todo el Turno';

  @override
  String get allStudentsInShift => 'Todos los estudiantes del turno';

  @override
  String get entireEducationalInstitution => 'Toda la institución educativa';

  @override
  String get deliveryOptions => 'Opciones de Entrega';

  @override
  String get pushNotification => 'Notificación Push';

  @override
  String get sendImmediateNotificationToDevice =>
      'Enviar notificación inmediata al dispositivo';

  @override
  String get sendCommunication => 'Enviar Comunicado';

  @override
  String get sendNow => 'Enviar Ahora';

  @override
  String get scheduled => 'Programada';

  @override
  String get sentSuccessfully => 'Enviada Exitosamente';

  @override
  String errorSaving(String entity) => 'Error al guardar $entity';
  // Implementing missing required getters
  @override
  String get emergency => 'Emergencia';

  @override
  String get exit => 'Salida';

  @override
  String get scheduleChange => 'Cambio de Horario';

  // Admin module missing methods
  @override
  String get adjustTolerance => 'Ajustar Tolerancia';
  @override
  String get after => 'Después';
  @override
  String get afternoon => 'Tarde';
  @override
  String get all => 'Todos';
  @override
  String get attendanceList => 'Lista de Asistencia';
  @override
  String get chooseClassForNotification => 'Elegir clase para notificación';
  @override
  String get chooseShiftToReceiveNotification =>
      'Elegir turno para recibir notificación';
  @override
  String get classes => 'Clases';
  @override
  String get classSelected => 'Clase Seleccionada';
  @override
  String get configureShiftSchedules => 'Configurar Horarios de Turnos';
  @override
  String get critical => 'Crítico';
  @override
  String get detailedRecords => 'Registros Detallados';
  @override
  String get educationLevels => 'Niveles Educativos';
  @override
  String get entry => 'Entrada';
  @override
  String get event => 'Evento';
  @override
  String get exampleCommunicationTitle => 'Ejemplo de Título de Comunicado';
  @override
  String get examplePermissionTitle => 'Ejemplo de Título de Permiso';
  @override
  String get filterByDay => 'Filtrar por Día';
  @override
  String get group => 'Grupo';
  @override
  String get informative => 'Informativo';
  @override
  String get lastStudentScanned => 'Último Estudiante Escaneado';
  @override
  String get message => 'Mensaje';
  @override
  String get messageTip => 'Consejo de Mensaje';
  @override
  String get min => 'Min';
  @override
  String get morning => 'Mañana';
  @override
  String get navigateToStudentDirectory =>
      'Navegar al Directorio de Estudiantes';
  @override
  String get needScheduleChanges => '¿Necesitas Cambios de Horario?';
  @override
  String get noAnnouncementsSent => 'No se han enviado anuncios';
  @override
  String get noAttendanceThisDate => 'No hay asistencia para esta fecha';
  @override
  String get noStudentsScanned => 'No hay estudiantes escaneados';
  @override
  String get noRecordsFound => 'No se encontraron registros';
  @override
  String get now => 'Ahora';
  @override
  String get ofTolerance => 'de Tolerancia';
  @override
  String get paymentReminder => 'Recordatorio de Pago';
  @override
  String get quickSelection => 'Selección Rápida';
  @override
  String get read => 'Leído';

  @override
  String get scheduleChangesDescription => 'Descripción de cambios de horario';
  @override
  String get scheduleReset => 'Horario Restablecido';

  @override
  String get scheduleSaved => 'Horario Guardado';
  @override
  String get schedulesByGroup => 'Horarios por Grupo';
  @override
  String get scanning => 'Escaneando';
  @override
  String get scanQRToRegisterAttendance =>
      'Escanear QR para Registrar Asistencia';
  @override
  String get searchInDirectory => 'Buscar en Directorio';
  @override
  String get searchStudent => 'Buscar Estudiante';
  @override
  String get selectAtLeastOneLevel => 'Selecciona al menos un nivel';
  @override
  String get selectClass => 'Seleccionar Clase';
  @override
  String get selectColor => 'Seleccionar Color';
  @override
  String get selectEducationLevels => 'Seleccionar Niveles Educativos';
  @override
  String get selectExportFormat => 'Seleccionar Formato de Exportación';
  @override
  String get selectRecipient => 'Seleccionar Destinatario';
  @override
  String get selectShift => 'Seleccionar Turno';
  @override
  String get selectShiftToSend => 'Seleccionar Turno para Enviar';
  @override
  String get selectStudentFromDirectory =>
      'Seleccionar Estudiante desde Directorio';
  @override
  String get sending => 'Enviando';
  @override
  String get sendNotification => 'Enviar Notificación';
  @override
  String get setEntryExitHoursForShifts =>
      'Establecer Horas de Entrada/Salida para Turnos';
  @override
  String get shiftSelected => 'Turno Seleccionado';
  @override
  String get startScanningToSeeRecords =>
      'Comienza a escanear para ver registros';
  @override
  String get status => 'Estado';
  @override
  String get subject => 'Materia';
  @override
  String get tapToChange => 'Tocar para Cambiar';
  @override
  String get tapToChooseClass => 'Toca para elegir clase';
  @override
  String get tapToChooseShift => 'Toca para elegir turno';
  @override
  String get time => 'Hora';

  @override
  String get titleRequired => 'El título es obligatorio';
  @override
  String get toleranceForLateArrivals => 'Tolerancia para Llegadas Tardías';
  @override
  String get totalStudents => 'Total de Estudiantes';
  @override
  String get tryAdjustingFilters => 'Intenta ajustar los filtros';
  @override
  String get unknown => 'Desconocido';

  // Additional admin methods
  @override
  String get absentStudents => 'Estudiantes Ausentes';
  @override
  String get basicInformation => 'Información Básica';
  @override
  String get calendarExplanationText =>
      'Explicación del calendario de asistencia';
  @override
  String get calendarLegend => 'Leyenda del Calendario';
  @override
  String get celebration => 'Celebración';
  @override
  String get citation => 'Citación';
  @override
  String get classSuspension => 'Suspensión de Clase';
  @override
  String get communicationContentHint =>
      'Ingresa el contenido de la comunicado aquí...';
  @override
  String get communicationTip => 'Consejo de Comunicado';
  @override
  String get contentRequired => 'El contenido es obligatorio';
  @override
  String get contacts => 'Contactos';
  @override
  String get createFirstAnnouncement => 'Crea tu primer anuncio';
  @override
  String get delivered => 'Entregado';
  @override
  String get editSubject => 'Editar Materia';
  @override
  String get emergencyContact => 'Contacto de Emergencia';
  @override
  String get enterMessageContent => 'Ingresa el contenido del mensaje';
  @override
  String get enterMessageTitle => 'Ingresa el título del mensaje';
  @override
  String get failed => 'Fallido';
  @override
  String get fieldTrip => 'Excursión';
  @override
  String get fullAttendance => 'Asistencia Completa';
  @override
  String get generate => 'Generar';
  @override
  String get imageExportDesc => 'Imagen para presentaciones';
  @override
  String get institutionalConfiguration => 'Configuración Institucional';
  @override
  String get lowAttendance => 'Asistencia Baja';
  @override
  String get messageContentHint => 'Ingresa el contenido del mensaje aquí...';
  @override
  String get noClasses => 'No hay Clases';
  @override
  String get occupation => 'Ocupación';
  @override
  String get partialAttendance => 'Asistencia Parcial';
  @override
  String get pdfExportDesc => 'Documento PDF para imprimir';
  @override
  String get pending => 'Pendiente';
  @override
  String get primaryContact => 'Contacto Principal';
  @override
  String get print => 'Imprimir';
  @override
  String get principal => 'Director';
  @override
  String get recentRecords => 'Registros Recientes';
  @override
  String get scheduleCall => 'Programar Llamada';
  @override
  String get schoolType => 'Tipo de Escuela';
  @override
  String get selectGradeAndGroup => 'Seleccionar Grado y Grupo';
  @override
  String get totalAnnouncementsSent => 'Total de anuncios enviados';
  @override
  String get aboutSchool => 'Acerca de la Escuela';

  @override
  String get appTitle => 'Alerta Escolar';

  @override
  String get homeTitle => 'Panel Principal';

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
  String get viewAll => 'Ver Todo';

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
  String get add => 'Añadir';

  @override
  String get grade => 'Grado';

  @override
  String get noData => 'Sin datos';

  @override
  String get addStudent => 'Añadir Estudiante';

  @override
  String get studentName => 'Nombre del Estudiante';

  @override
  String get studentGrade => 'Grado';

  @override
  String get noStudentsTitle => 'No hay estudiantes registrados';

  @override
  String get noStudentsMessage =>
      'Registre a sus hijos para comenzar a monitorizar su actividad escolar';

  @override
  String get noStudents => 'Sin Estudiantes';

  @override
  String get addFirstStudent => 'Añade tu primer estudiante';

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
  String studentsHaveToleranceAfterEntryTime(int minutes) =>
      'Los estudiantes tienen $minutes minutos de tolerancia después de la hora de entrada';

  @override
  String recordCount(int count) => '$count registros';

  @override
  String contactVia(String method) => 'Contactar vía $method';

  @override
  String scheduleOf(String name) => 'Horario de $name';

  @override
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
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
  String get dangerZone => 'Zona de Peligro';

  @override
  String get dangerZoneDesc => 'Acciones irreversibles';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get changePasswordDesc => 'Actualiza la contraseña de tu cuenta';

  @override
  String get downloadData => 'Descargar Datos';

  @override
  String get downloadDataDesc => 'Exporta los datos de tu cuenta';

  @override
  String get clearCache => 'Limpiar Caché';

  @override
  String get clearCacheDesc => 'Limpiar el caché y archivos temporales';

  @override
  String get twoFactorAuth => 'Autenticación de Dos Factores';

  @override
  String get twoFactorAuthDesc => 'Habilita 2FA para mayor seguridad';

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
  String get accountDisabled => 'Cuenta deshabilitada temporalmente';

  @override
  String get accountDeletionStarted =>
      'Proceso de eliminación de cuenta iniciado';

  @override
  String get navigatingToPasswordChange =>
      'Navegando a cambio de contraseña...';

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
  String get email => 'Correo Electrónico';

  @override
  String get primaryEmailAddress => 'Dirección de Correo Principal';

  @override
  String get notRegistered => 'No Registrado';

  @override
  String get securityInformation => 'Información de Seguridad';

  @override
  String get accountStatus => 'Estado de la Cuenta';

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
      'Contacta al administrador para modificar la información';

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
  String get addNewContact => 'Añadir nuevo contacto';

  @override
  String get familyInformation => 'Información Familiar';

  @override
  String get manageFamilyContacts => 'Gestionar contactos familiares';

  @override
  String get noFamilyContacts => 'Sin contactos familiares';

  @override
  String get addFamilyContactsEmergency =>
      'Añadir contactos familiares para emergencias';
  @override
  String get login => 'Iniciar Sesión';

  @override
  String get registerWithEmail => 'Registrarse con Correo';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get nameRequired => 'El nombre es requerido';

  @override
  String get phone => 'Teléfono';

  @override
  String get phoneRequired => 'El teléfono es requerido';

  @override
  String get emailOptional => 'Correo (Opcional)';

  @override
  String get enterValidEmail => 'Ingresa un correo válido';

  @override
  String get enter => 'Ingresar';

  @override
  String get relationship => 'Relación';

  @override
  String get clear => 'Limpiar';

  @override
  String get addContact => 'Añadir Contacto';

  @override
  String get familyContactsUsedBySchool =>
      'Los contactos familiares son utilizados por la escuela para emergencias';

  @override
  String get familyContactAddedSuccessfully =>
      'Contacto familiar añadido exitosamente';

  @override
  String get errorAddingContact => 'Error al añadir contacto';

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
  String get notificationInfoText => 'Configura cómo recibes notificaciones';

  @override
  String get soundDefault => 'Predeterminado';

  @override
  String get soundBell => 'Campana';

  @override
  String get soundChime => 'Carillón';

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
  String get firstNameRequired => 'El nombre es requerido';

  @override
  String get lastName => 'Apellido';

  @override
  String get lastNameRequired => 'El apellido es requerido';

  @override
  String get emailRequired => 'El correo electrónico es requerido';

  @override
  String get accountInformation => 'Información de la Cuenta';

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
  String get selectFromGallery => 'Seleccionar de la Galería';

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
  String get lastNamesRequired => 'Los apellidos son requeridos';

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
  String get errorUpdatingInformation => 'Error al actualizar la información';

  // Password Security - Spanish
  @override
  String get securityTips => 'Consejos de Seguridad';

  @override
  String get changePasswordSubtitle => 'Cambia la contraseña de tu cuenta';

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
  String get usernameRequired => 'El nombre de usuario es requerido';

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
      'La contraseña es requerida para la confirmación';

  @override
  String get usernameRequirements => 'Requisitos del Nombre de Usuario';

  @override
  String get minimumCharacters => 'Mínimo 3 caracteres';

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
  String get errorChangingUsername => 'Error al cambiar el nombre de usuario';

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
  String get emergencyDataAndContacts => 'Datos y contactos de emergencia';

  @override
  String get preferences => 'Preferencias';

  @override
  String get configureAlertsAndReminders =>
      'Configurar alertas y recordatorios';

  @override
  String get helpCenter => 'Centro de Ayuda';

  @override
  String get faqAndGuides => 'Preguntas Frecuentes y Guías';

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
  String get reportsAndStatistics => 'Informes y Estadísticas';

  @override
  String get summary => 'Resumen';

  @override
  String get activity => 'Actividad';

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
  String get trendChartComingSoon => 'Gráfico de tendencia próximamente';

  @override
  String get noStudentsForAttendanceReport =>
      'No hay estudiantes disponibles para el informe de asistencia';

  @override
  String get attendanceReport => 'Informe de Asistencia';

  @override
  String get noActivity => 'Sin Actividad';

  @override
  String get noNotificationsInSelectedPeriod =>
      'Sin notificaciones en el período seleccionado';

  @override
  String get activityReport => 'Informe de Actividad';

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
  String get noStudentsLinked => 'No hay estudiantes vinculados';

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
      'Añade tu primer estudiante para comenzar a monitorizar su actividad escolar';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  // Add Student - Spanish
  @override
  String get instructions => 'Instrucciones';

  @override
  String get linkStudentInstructions =>
      'Vincula a un estudiante usando su código QR o código clave proporcionado por la escuela';

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
      'Ingresa el código clave del estudiante manualmente';

  @override
  String get keyCode => 'Código Clave';

  @override
  String get keyCodeExample => 'p. ej., ESTU123456';

  @override
  String get pleaseEnterKeyCode => 'Por favor, ingresa el código clave';

  @override
  String get keyCodeMinLength =>
      'El código clave debe tener al menos 6 caracteres';

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
  String get studentId => 'ID de Estudiante';

  @override
  String get noId => 'Sin ID';

  @override
  String get keyInformation => 'Información Clave';

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
  String get errorLoadingSchedule => 'Error al cargar el horario';

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
      'Sincroniza los datos automáticamente al conectarse';

  @override
  String get offlineMode => 'Modo Offline';

  @override
  String get offlineModeDescription =>
      'Trabaja sin conexión cuando no hay conexión disponible';

  @override
  String get privacyAnalytics => 'Privacidad y Análisis';

  @override
  String get analyticsEnabled => 'Análisis Habilitado';

  @override
  String get analyticsDescription =>
      'Ayuda a mejorar la aplicación compartiendo datos de uso';

  @override
  String get crashReporting => 'Informes de Fallos';

  @override
  String get crashReportingDescription =>
      'Envía informes de fallos para ayudar a solucionar problemas';

  @override
  String get storageCache => 'Almacenamiento y Caché';

  @override
  String get cacheSize => 'Tamaño de Caché';

  @override
  String get clearCacheDescription => 'Limpiar caché y archivos temporales';

  @override
  String get downloadQuality => 'Calidad de Descarga';

  @override
  String get appUpdates => 'Actualizaciones de la App';

  @override
  String get autoUpdate => 'Actualización Automática';

  @override
  String get autoUpdateDescription =>
      'Descargar actualizaciones de la app automáticamente';

  @override
  String get betaFeatures => 'Funciones Beta';

  @override
  String get betaFeaturesDescription => 'Habilitar funciones experimentales';

  @override
  String get appSettings => 'Configuración de la App';

  @override
  String get appConfiguration => 'Configuración de la App';

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
  String get lastLogin => 'Último Inicio de Sesión';

  // Missing keys for home view - Spanish
  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get newNotifications => 'nuevas';

  @override
  String get entryRegistered => 'Entrada registrada';

  @override
  String get exitRegistered => 'Salida registrada';

  @override
  String get arrivedLate => 'Llegó tarde';

  @override
  String get announcement => 'Anuncio';

  @override
  String get tapToViewDetails => 'Toca para ver detalles';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get sevenDays => '7 días';

  @override
  String get oneMonth => '1 mes';

  @override
  String get weeklyAttendance => 'Asistencia Semanal';

  @override
  String get monthlyAttendance => 'Asistencia Mensual';

  @override
  String get plusFivePercent => '+5% vs anterior';

  @override
  String get plusTwoPercent => '+2% vs anterior';
  @override
  String get attendances => 'Asistencias';
  @override
  String get lateArrivals => 'Llegadas Tardías';
  @override
  String get todaysSchedule => 'Horario de Hoy';
  @override
  String get morningClasses => 'Clases de Mañana';
  @override
  String get afternoonClasses => 'Clases de Tarde';
  @override
  String get extracurricularActivities => 'Actividades Extracurriculares';
  @override
  String get mathSpanishSciences => 'Matemáticas, Español, Ciencias';
  @override
  String get historyPhysicalEducation => 'Historia, Educación Física';
  @override
  String get chessClub => 'Club de Ajedrez';
  @override
  String get inProgress => 'En progreso';
  @override
  String get quickActions => 'Acciones Rápidas';
  @override
  String get viewHistory => 'Ver historial';
  @override
  String get notificationsWillAppearHere =>
      'Las notificaciones aparecerán aquí';
  @override
  String get addStudentToStart => 'Añade un estudiante para comenzar';

  // Missing keys for notifications view - Spanish
  @override
  String get categories => 'Categorías';
  @override
  String get accessAlerts => 'Acceder a Alertas';
  @override
  String get fourteenDays => '14 días';
  @override
  String get accessRecordsAndAlerts => 'acceder a registros y alertas';

  // Schedule view additional keys - Spanish
  @override
  String get weeklySchedule => 'Horario Semanal';
  @override
  String get selectStudent => 'Seleccionar Estudiante';

  // Inside the AppLocalizationsEs class, add all these missing translations:

  @override
  String get totalScanned => 'Total Escaneados';

  @override
  String get presentStudents => 'Estudiantes Presentes';

  @override
  String get todayAttendance => 'Asistencia de Hoy';

  @override
  String get lateStudents => 'Estudiantes Tardíos';

  @override
  String get scannedBy => 'Escaneado por';

  @override
  String get entryTime => 'Hora de Entrada';

  @override
  String get searchStudents => 'Buscar Estudiantes';

  @override
  String get filterBy => 'Filtrar por';

  @override
  String get allGrades => 'Todos los Grados';

  @override
  String get allGroups => 'Todos los Grupos';

  @override
  String get activeStudents => 'Estudiantes Activos';

  @override
  String get inactiveStudents => 'Estudiantes Inactivos';

  @override
  String get studentsFound => 'Estudiantes Encontrados';

  @override
  String get noStudentsFound => 'No se Encontraron Estudiantes';

  @override
  String get studentProfile => 'Perfil del Estudiante';

  @override
  String get familyContacts => 'Contactos Familiares';

  @override
  String get attendanceHistory => 'Historial de Asistencia';

  @override
  String get academicRecord => 'Registro Académico';

  @override
  String get contactParents => 'Contactar Padres';

  @override
  String get editStudent => 'Editar Estudiante';

  @override
  String get turn => 'Turno';

  @override
  String get morningShift => 'Turno Matutino';

  @override
  String get afternoonShift => 'Turno Vespertino';

  @override
  String get activated => 'Activado';

  @override
  String get deactivated => 'Desactivado';

  @override
  String get timeRemaining => 'Tiempo Restante';

  @override
  String get days => 'Días';

  @override
  String get entryTolerance => 'Tolerancia de Entrada';

  @override
  String get lateTolerance => 'Tolerancia de Tardanza';

  @override
  String get exitTime => 'Hora de Salida';

  @override
  String get configureSchedules => 'Configurar Horarios';

  @override
  String get schoolInfo => 'Información de la Escuela';

  @override
  String get schoolName => 'Nombre de la Escuela';

  @override
  String get schoolAddress => 'Dirección de la Escuela';

  @override
  String get schoolPhone => 'Teléfono';

  @override
  String get schoolEmail => 'Correo';

  @override
  String get principalName => 'Nombre del Director';

  @override
  String get schoolLogo => 'Logo de la Escuela';

  @override
  String get schoolColors => 'Colores de la Escuela';

  @override
  String get primaryColor => 'Color Primario';

  @override
  String get secondaryColor => 'Color Secundario';

  @override
  String get accentColor => 'Color de Acento';

  @override
  String get updateSettings => 'Actualizar Configuración';

  @override
  String get settingsUpdated => 'Configuración Actualizada';

  @override
  String get selectDateRange => 'Seleccionar Rango de Fechas';

  @override
  String get startDate => 'Fecha de Inicio';

  @override
  String get endDate => 'Fecha de Fin';

  @override
  String get generateReport => 'Generar Informe';

  @override
  String get exportReport => 'Exportar Informe';

  @override
  String get attendanceRate => 'Tasa de Asistencia';

  @override
  String get punctualityRate => 'Tasa de Puntualidad';

  @override
  String get absenceRate => 'Tasa de Ausencia';

  @override
  String get totalDays => 'Días Totales';

  @override
  String get presentDays => 'Días Presentes';

  @override
  String get lateDays => 'Días Tardíos';

  @override
  String get absentDays => 'Días Ausentes';

  @override
  String get monthlyReport => 'Informe Mensual';

  @override
  String get weeklyReport => 'Informe Semanal';

  @override
  String get dailyReport => 'Informe Diario';

  @override
  String get byGrade => 'Por Grado';

  @override
  String get byGroup => 'Por Grupo';

  @override
  String get byStudent => 'Por Estudiante';

  @override
  String get attendanceCalendar => 'Calendario de Asistencia';

  @override
  String get viewDetails => 'Ver Detalles';

  @override
  String get scannedStudents => 'Estudiantes Escaneados';

  @override
  String get scanTime => 'Hora de Escaneo';

  @override
  String get priority => 'Prioridad';

  @override
  String get urgent => 'Urgente';

  @override
  String get send => 'Enviar';

  @override
  String get announcementSent => 'Anuncio Enviado';

  @override
  String get timeSettings => 'Configuración de Tiempo';

  @override
  String get toleranceSettings => 'Configuración de Tolerancia';

  @override
  String get minutes => 'Minutos';

  @override
  String get editingScheduleFor => 'Editando horario para';

  @override
  String get emergencyPhone => 'Teléfono de Emergencia';

  @override
  String get website => 'Sitio Web';

  @override
  String get socialMedia => 'Redes Sociales';

  @override
  String get invalidEmail => 'Correo Inválido';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get saving => 'Guardando';

  @override
  String get schoolBranding => 'Marca de la Escuela';

  @override
  String get schoolCode => 'Código';

  @override
  String get foundedYear => 'Fundación';

  @override
  String get description => 'Descripción';

  @override
  String get changeLogo => 'Cambiar Logo';

  @override
  String get uploadLogo => 'Subir Logo';

  @override
  String get logoUploaded => 'Logo Subido';

  @override
  String get noLogoUploaded => 'No se ha Subido Logo';

  @override
  String get preview => 'Vista Previa';

  // Inside the AppLocalizationsEs class, add all these missing translations:

  @override
  String get selectReportType => 'Seleccionar Tipo de Informe';

  @override
  String get punctualityReport => 'Informe de Puntualidad';

  @override
  String get absenceReport => 'Informe de Ausencias';

  @override
  String get summaryReport => 'Informe Resumen';

  @override
  String get reportFilters => 'Filtros de Informe';

  @override
  String get reportPeriod => 'Período del Informe';

  @override
  String get customPeriod => 'Período Personalizado';

  @override
  String get exportAs => 'Exportar como';

  @override
  String get exportConfirm => 'El informe se exportará en formato';

  @override
  String get export => 'Exportar';

  @override
  String get exporting => 'Exportando';

  @override
  String get generating => 'Generando';

  @override
  String get exportedSuccessfully => 'Exportado exitosamente en formato';

  @override
  String get attendanceReportDesc =>
      'Informe detallado de asistencia por período';

  @override
  String get punctualityReportDesc => 'Análisis de tardanzas y puntualidad';

  @override
  String get absenceReportDesc => 'Estadísticas de ausentismo escolar';

  @override
  String get summaryReportDesc => 'Resumen de todas las métricas';

  @override
  String get adminActions => 'Acciones de Administrador';

  @override
  String get primaryActions => 'Acciones Principales';

  @override
  String get communicationActions => 'Acciones de Comunicado';

  @override
  String get administrativeActions => 'Acciones Administrativas';

  @override
  String get emergencyActions => 'Acciones de Emergencia';

  @override
  String get sendMessage => 'Enviar Mensaje';

  @override
  String get sendEmail => 'Enviar Correo';

  @override
  String get addNote => 'Añadir Nota';

  @override
  String get printProfile => 'Imprimir Perfil';

  @override
  String get contact => 'Contacto';

  @override
  String get schedule => 'Horario';

  @override
  String get emergencyContactInitiated => 'Contacto de Emergencia Iniciado';

  @override
  String get sendMessageConfirm => '¿Enviar mensaje a los padres?';

  @override
  String get sendEmailConfirm => '¿Enviar correo a los padres?';

  @override
  String get addNoteConfirm => '¿Añadir nota al registro del estudiante?';

  @override
  String get scheduleCallConfirm => '¿Programar llamada con los padres?';

  @override
  String get generateReportConfirm => '¿Generar informe del estudiante?';

  @override
  String get printProfileConfirm => '¿Imprimir perfil del estudiante?';

  @override
  String get emergencyContactConfirm =>
      '¿Iniciar protocolo de contacto de emergencia?';

  @override
  String get editStudentConfirm => '¿Editar información del estudiante?';

  @override
  String get grades => 'Grados';

  @override
  String get groups => 'Grupos';

  @override
  String get last30Days => 'Últimos 30 Días';

  @override
  String get viewAllRecords => 'Ver Todos los Registros';

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

  // Admin module keys
  @override
  String get adminDashboard => 'Panel de Administración';
  @override
  String get attendanceControl => 'Control de Asistencia';
  @override
  String get studentsDirectory => 'Directorio de Estudiantes';
  @override
  String get scheduleManagement => 'Gestión de Horarios';
  @override
  String get schoolSettings => 'Configuración de la Escuela';
  @override
  String get reports => 'Informes';
  @override
  String get scanQR => 'Escanear QR';
  @override
  String get attendanceRegistered => 'Asistencia Registrada';
  @override
  String get createAnnouncement => 'Crear Anuncio';
  @override
  String get sendToGroup => 'Enviar a Grupo';
  @override
  String get sendToStudent => 'Enviar a Estudiante';
  @override
  String get messageTitle => 'Título del Mensaje';
  @override
  String get messageContent => 'Contenido del Mensaje';
  @override
  String get selectGrade => 'Seleccionar Grado';
  @override
  String get selectGroup => 'Seleccionar Grupo';
}
