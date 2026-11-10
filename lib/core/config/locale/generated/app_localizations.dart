import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Label for the language switcher
  ///
  /// In en, this message translates to:
  /// **'Language Change'**
  String get languageChange;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'Use device setting'**
  String get systemMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Dismisses a dialog without taking the action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Default label for the confirming action of a dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Screen-reader label for skeleton and loading placeholders
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Shown when navigation targets an unknown route
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Label for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// No description provided for @directComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Direct booking is coming soon'**
  String get directComingSoon;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @featuredServices.
  ///
  /// In en, this message translates to:
  /// **'Featured services'**
  String get featuredServices;

  /// No description provided for @popularServices.
  ///
  /// In en, this message translates to:
  /// **'Popular services'**
  String get popularServices;

  /// No description provided for @ourTeam.
  ///
  /// In en, this message translates to:
  /// **'Our team'**
  String get ourTeam;

  /// No description provided for @latestReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest reviews'**
  String get latestReviews;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed now'**
  String get closedNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get searchServices;

  /// No description provided for @allServices.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get allServices;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services match your search'**
  String get noServices;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Specialists'**
  String get staff;

  /// No description provided for @allSpecialists.
  ///
  /// In en, this message translates to:
  /// **'All specialists'**
  String get allSpecialists;

  /// No description provided for @noStaff.
  ///
  /// In en, this message translates to:
  /// **'No specialists are available yet'**
  String get noStaff;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @busyHours.
  ///
  /// In en, this message translates to:
  /// **'Busy hours'**
  String get busyHours;

  /// No description provided for @busyHoursNote.
  ///
  /// In en, this message translates to:
  /// **'Typical activity only; this does not show appointment availability.'**
  String get busyHoursNote;

  /// No description provided for @noBusyHours.
  ///
  /// In en, this message translates to:
  /// **'Busy hours are unavailable right now'**
  String get noBusyHours;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @anySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Any specialist'**
  String get anySpecialist;

  /// No description provided for @maxDuration.
  ///
  /// In en, this message translates to:
  /// **'Maximum duration'**
  String get maxDuration;

  /// No description provided for @anyDuration.
  ///
  /// In en, this message translates to:
  /// **'Any duration'**
  String get anyDuration;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @defaultSort.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get defaultSort;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get priceHighToLow;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get seeDetails;

  /// No description provided for @relatedServices.
  ///
  /// In en, this message translates to:
  /// **'Related services'**
  String get relatedServices;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'Description is not available yet'**
  String get noDescription;

  /// No description provided for @bestTimes.
  ///
  /// In en, this message translates to:
  /// **'Usually quieter times'**
  String get bestTimes;

  /// No description provided for @closedAtHour.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedAtHour;

  /// No description provided for @quiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get quiet;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @noCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh and check again.'**
  String get noCategoriesHint;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your internet connection and try again.'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your internet connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the information you entered and try again.'**
  String get errorValidation;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorForbidden;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @reliabilityScore.
  ///
  /// In en, this message translates to:
  /// **'Reliability score'**
  String get reliabilityScore;

  /// No description provided for @reliabilityHint.
  ///
  /// In en, this message translates to:
  /// **'Keeping appointments and avoiding late cancellations raises your score.'**
  String get reliabilityHint;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get invalidCredentials;

  /// No description provided for @splashEyebrow.
  ///
  /// In en, this message translates to:
  /// **'BEAUTY & CARE'**
  String get splashEyebrow;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your moment to shine'**
  String get splashTagline;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience'**
  String get splashPreparing;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @chooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose a day'**
  String get chooseDay;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseTime;

  /// No description provided for @noAvailability.
  ///
  /// In en, this message translates to:
  /// **'No appointments are available'**
  String get noAvailability;

  /// No description provided for @bookingNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get bookingNotes;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCode;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied'**
  String get couponApplied;

  /// No description provided for @payAtPlace.
  ///
  /// In en, this message translates to:
  /// **'Pay at the venue'**
  String get payAtPlace;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @signInToBook.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to book'**
  String get signInToBook;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookings;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'You have no upcoming bookings.'**
  String get noUpcomingBookings;

  /// No description provided for @noPastBookings.
  ///
  /// In en, this message translates to:
  /// **'You have no past bookings.'**
  String get noPastBookings;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book an appointment'**
  String get bookAppointment;

  /// No description provided for @signInForBookings.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and manage your bookings.'**
  String get signInForBookings;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetails;

  /// No description provided for @bookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Booking number'**
  String get bookingNumber;

  /// No description provided for @bookingCode.
  ///
  /// In en, this message translates to:
  /// **'Booking code'**
  String get bookingCode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason (optional)'**
  String get cancellationReason;

  /// No description provided for @lateCancellation.
  ///
  /// In en, this message translates to:
  /// **'This is a late cancellation.'**
  String get lateCancellation;

  /// No description provided for @rescheduleBooking.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get rescheduleBooking;

  /// No description provided for @reviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Review visit'**
  String get reviewBooking;

  /// No description provided for @reviewComment.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get reviewComment;

  /// No description provided for @joinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get joinWaitlist;

  /// No description provided for @myWaitlist.
  ///
  /// In en, this message translates to:
  /// **'My waitlist'**
  String get myWaitlist;

  /// No description provided for @waitlistDetails.
  ///
  /// In en, this message translates to:
  /// **'Waitlist details'**
  String get waitlistDetails;

  /// No description provided for @waitlistDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a day and time window. We\'ll let you know if an appointment opens.'**
  String get waitlistDescription;

  /// No description provided for @waitlistSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get waitlistSelectDate;

  /// No description provided for @waitlistFromTime.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get waitlistFromTime;

  /// No description provided for @waitlistToTime.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get waitlistToTime;

  /// No description provided for @waitlistTimeError.
  ///
  /// In en, this message translates to:
  /// **'The end time must be after the start time.'**
  String get waitlistTimeError;

  /// No description provided for @noWaitlistEntries.
  ///
  /// In en, this message translates to:
  /// **'No active waitlist entries'**
  String get noWaitlistEntries;

  /// No description provided for @waitlistOffer.
  ///
  /// In en, this message translates to:
  /// **'An appointment is available'**
  String get waitlistOffer;

  /// No description provided for @claimOffer.
  ///
  /// In en, this message translates to:
  /// **'Claim appointment'**
  String get claimOffer;

  /// No description provided for @waitlistClaimed.
  ///
  /// In en, this message translates to:
  /// **'Appointment claimed'**
  String get waitlistClaimed;

  /// No description provided for @leaveWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Leave waitlist'**
  String get leaveWaitlist;

  /// No description provided for @leaveWaitlistConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this waitlist entry?'**
  String get leaveWaitlistConfirmation;

  /// No description provided for @waitlistRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the waitlist'**
  String get waitlistRemoved;

  /// No description provided for @queueDisabled.
  ///
  /// In en, this message translates to:
  /// **'Live queue is unavailable at this venue'**
  String get queueDisabled;

  /// No description provided for @queueClosed.
  ///
  /// In en, this message translates to:
  /// **'Live queue is closed'**
  String get queueClosed;

  /// No description provided for @queueNotAccepting.
  ///
  /// In en, this message translates to:
  /// **'Live queue is not accepting tickets'**
  String get queueNotAccepting;

  /// No description provided for @queueAccepting.
  ///
  /// In en, this message translates to:
  /// **'Live queue is open'**
  String get queueAccepting;

  /// No description provided for @liveQueue.
  ///
  /// In en, this message translates to:
  /// **'Live queue'**
  String get liveQueue;

  /// No description provided for @queueNowServing.
  ///
  /// In en, this message translates to:
  /// **'Now serving'**
  String get queueNowServing;

  /// No description provided for @queueList.
  ///
  /// In en, this message translates to:
  /// **'Queue list'**
  String get queueList;

  /// No description provided for @queueNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No tickets are listed yet. Pull down to refresh.'**
  String get queueNoEntries;

  /// No description provided for @queueWaitingCount.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get queueWaitingCount;

  /// No description provided for @queueServedToday.
  ///
  /// In en, this message translates to:
  /// **'Served today'**
  String get queueServedToday;

  /// No description provided for @queueEstimatedWait.
  ///
  /// In en, this message translates to:
  /// **'Estimated wait'**
  String get queueEstimatedWait;

  /// No description provided for @queueMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get queueMinutes;

  /// No description provided for @myQueueTicket.
  ///
  /// In en, this message translates to:
  /// **'My queue ticket'**
  String get myQueueTicket;

  /// No description provided for @queuePosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get queuePosition;

  /// No description provided for @joinQueue.
  ///
  /// In en, this message translates to:
  /// **'Take a ticket'**
  String get joinQueue;

  /// No description provided for @cancelQueueTicket.
  ///
  /// In en, this message translates to:
  /// **'Cancel ticket'**
  String get cancelQueueTicket;

  /// No description provided for @cancelQueueConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel your queue ticket?'**
  String get cancelQueueConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
