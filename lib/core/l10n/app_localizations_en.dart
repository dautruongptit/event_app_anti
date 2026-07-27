// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Event Reminder';

  @override
  String get home => 'Home';

  @override
  String get events => 'Events';

  @override
  String get relatives => 'Relatives';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get createEvent => 'Create Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get eventType => 'Event Type';

  @override
  String get eventDate => 'Event Date';

  @override
  String get createRelative => 'Add Relative';

  @override
  String get editRelative => 'Edit Relative';

  @override
  String get deleteRelative => 'Delete Relative';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get uploadAvatar => 'Upload Avatar';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String daysUntil(Object days) {
    return '$days days left';
  }

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noData => 'No data';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get birthday => 'Birthday';

  @override
  String get anniversary => 'Anniversary';

  @override
  String get holiday => 'Holiday';

  @override
  String get housing => 'Housing';

  @override
  String get bill => 'Bill';

  @override
  String get shopping => 'Shopping';

  @override
  String get other => 'Other';

  @override
  String get family => 'Family';

  @override
  String get spouse => 'Spouse';

  @override
  String get children => 'Children';

  @override
  String get friends => 'Friends';
}
