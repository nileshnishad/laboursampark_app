import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'jobs': 'Jobs',
      'my_jobs': 'My Jobs',
      'labours': 'Labours',
      'contractors': 'Contractors',
      'history': 'History',
      'profile': 'Profile',
      'settings': 'Settings',
      'light_mode': 'Light mode',
      'dark_mode': 'Dark mode',
      'system_default': 'System default',
      'language': 'Language',
      'select_language': 'Select language',
      'cancel': 'Cancel',
      'english': 'English',
      'hindi': 'हिन्दी',
      'marathi': 'मराठी',
      'logout': 'Logout',
      'my_id_card': 'My ID Card',
      'creating_payment': 'Creating payment link...',
      'verifying_payment': 'Verifying payment...',
      'subscription_activated': 'Subscription activated successfully!',
      'payment_received_info':
          'Payment received! If not reflected, check back in a few minutes.',
      'payment_successful': 'Payment successful! Subscription activated.',
      'payment_failed': 'Payment failed or was cancelled. Please try again.',
      'profile_hidden': 'Your profile is hidden',
      'go_now': 'Go Now',
      'subscribe_now': 'Subscribe Now',
      'proceed_to_payment': 'Proceed to Payment',
      'could_not_create_payment_link': 'Could not create payment link',
      'invalid_payment_link': 'Invalid payment link received',
      'could_not_open_browser': 'Could not open browser. Please try again.',
      'complete_payment_message':
          'Complete payment in browser, then return to the app.',
      'loading_subscription_details': 'Loading subscription details...',
      'session_expired': 'Session expired. Please login again.',
    },
    'hi': {
      'jobs': 'नौकरियाँ',
      'my_jobs': 'मेरी नौकरियाँ',
      'labours': 'मज़दूर',
      'contractors': 'ठेकेदार',
      'history': 'इतिहास',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'light_mode': 'लाइट मोड',
      'dark_mode': 'डार्क मोड',
      'system_default': 'सिस्टम डिफ़ॉल्ट',
      'language': 'भाषा',
      'select_language': 'भाषा चुनें',
      'cancel': 'रद्द करें',
      'english': 'English',
      'hindi': 'हिन्दी',
      'marathi': 'मराठी',
      'logout': 'लॉगआउट',
      'my_id_card': 'मेरी आईडी कार्ड',
      'creating_payment': 'भुगतान लिंक बना रहे हैं...',
      'verifying_payment': 'भुगतान सत्यापित किया जा रहा है...',
      'subscription_activated': 'सब्सक्रिप्शन सफलतापूर्वक सक्रिय हो गया!',
      'payment_received_info':
          'भुगतान प्राप्त हुआ! यदि परिलक्षित नहीं हुआ तो कुछ समय बाद देखें।',
      'payment_successful': 'भुगतान सफल! सब्सक्रिप्शन सक्रिय हो गया।',
      'payment_failed': 'भुगतान विफल या रद्द किया गया। कृपया पुनः प्रयास करें।',
      'profile_hidden': 'आपकी प्रोफ़ाइल छुपी हुई है',
      'go_now': 'अब जाएँ',
      'subscribe_now': 'अभी सदस्यता लें',
      'proceed_to_payment': 'भुगतान के लिए आगे बढ़ें',
      'could_not_create_payment_link': 'भुगतान लिंक नहीं बनाया जा सका',
      'invalid_payment_link': 'अमान्य भुगतान लिंक प्राप्त हुआ',
      'could_not_open_browser':
          'ब्राउज़र खोलने में विफल। कृपया पुनः प्रयास करें।',
      'complete_payment_message':
          'ब्राउज़र में भुगतान पूरा करें, फिर ऐप पर लौटें।',
      'loading_subscription_details': 'सदस्यता विवरण लोड किया जा रहा है...',
      'session_expired': 'सत्र समाप्त हुआ। कृपया फिर से लॉगिन करें।',
    },
    'mr': {
      'jobs': 'नोकऱ्या',
      'my_jobs': 'माझ्या नोकऱ्या',
      'labours': 'कामगार',
      'contractors': 'ठेकेदार',
      'history': 'इतिहास',
      'profile': 'प्रोफाइल',
      'settings': 'सेटिंग्स',
      'light_mode': 'लाइट मोड',
      'dark_mode': 'डार्क मोड',
      'system_default': 'सिस्टम डीफॉल्ट',
      'language': 'भाषा',
      'select_language': 'भाषा निवडा',
      'cancel': 'रद्द करा',
      'english': 'English',
      'hindi': 'हिन्दी',
      'marathi': 'मराठी',
      'logout': 'लॉगआउट',
      'my_id_card': 'माझी आयडी कार्ड',
      'creating_payment': 'पेमेंट लिंक तयार करत आहोत...',
      'verifying_payment': 'पेमेंट पडताळणी केली जात आहे...',
      'subscription_activated':
          'सबस्क्रिप्शन यशस्वीरित्या सक्रिय केले गेले आहे!',
      'payment_received_info':
          'पेमेंट प्राप्त झाले! प्रतिबिंबित न झाल्यास काही वेळाने तपासा.',
      'payment_successful': 'पेमेंट यशस्वी! सबस्क्रिप्शन सक्रिय झाले.',
      'payment_failed':
          'पेमेंट अयशस्वी किंवा रद्द केले गेले. कृपया पुन्हा प्रयत्न करा.',
      'profile_hidden': 'तुमचे प्रोफाइल लपले आहे',
      'go_now': 'आता जा',
      'subscribe_now': 'आता सदस्यता घ्या',
      'proceed_to_payment': 'पेमेंटसाठी पुढे जा',
      'could_not_create_payment_link': 'पेमेंट लिंक तयार करता आले नाही',
      'invalid_payment_link': 'अवैध पेमेंट लिंक प्राप्त झाली',
      'could_not_open_browser':
          'ब्राउझर उघडण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
      'complete_payment_message':
          'ब्राउझरमध्ये पेमेंट पूर्ण करा, नंतर अ‍ॅपवर परत या.',
      'loading_subscription_details': 'सदस्यता तपशील लोड करीत आहोत...',
      'session_expired': 'सत्र समाप्त झाले. कृपया पुन्हा लॉगिन करा.',
    },
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get settings => _t('settings');
  String get lightMode => _t('light_mode');
  String get darkMode => _t('dark_mode');
  String get systemDefault => _t('system_default');
  String get language => _t('language');
  String get selectLanguage => _t('select_language');
  String get cancel => _t('cancel');
  String get english => _t('english');
  String get hindi => _t('hindi');
  String get marathi => _t('marathi');
  String get logout => _t('logout');
  String get myIdCard => _t('my_id_card');
  String get creatingPayment => _t('creating_payment');
  String get verifyingPayment => _t('verifying_payment');
  String get subscriptionActivated => _t('subscription_activated');
  String get paymentReceivedInfo => _t('payment_received_info');
  String get paymentSuccessful => _t('payment_successful');
  String get paymentFailed => _t('payment_failed');
  String get profileHidden => _t('profile_hidden');
  String get goNow => _t('go_now');
  String get subscribeNow => _t('subscribe_now');
  String get proceedToPayment => _t('proceed_to_payment');
  String get couldNotCreatePaymentLink => _t('could_not_create_payment_link');
  String get invalidPaymentLink => _t('invalid_payment_link');
  String get couldNotOpenBrowser => _t('could_not_open_browser');
  String get completePaymentMessage => _t('complete_payment_message');
  String get loadingSubscriptionDetails => _t('loading_subscription_details');
  String get sessionExpired => _t('session_expired');
  String get jobs => _t('jobs');
  String get myJobs => _t('my_jobs');
  String get labours => _t('labours');
  String get contractors => _t('contractors');
  String get history => _t('history');
  String get profile => _t('profile');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
