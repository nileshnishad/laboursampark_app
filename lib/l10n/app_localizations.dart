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
      'register_as_contractor': 'Register as Contractor',
      'register_as_subcontractor': 'Register as Sub-Contractor',
      'register_as_labour': 'Register as Labour',
      'company_logo_uploaded': 'Company logo uploaded ✓',
      'tap_to_add_company_logo': 'Tap to add company logo',
      'date_of_birth': 'Date of Birth',
      'account_security': 'Account Security',
      'password_requirements_label': 'Password Requirements:',
      'at_least_8_chars': 'At least 8 characters',
      'one_uppercase': 'One uppercase letter (A-Z)',
      'one_lowercase': 'One lowercase letter (a-z)',
      'one_number': 'One number (0-9)',
      'creating_account': 'Creating Account...',
      'create_account': 'Create Account',
      'welcome_back': 'Welcome Back',
      'sign_in_to_your_account': 'Sign in to your account',
      'email_or_mobile_number': 'Email or mobile number',
      'email_or_mobile_hint': 'name@example.com or +91xxxxxxxxxx',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'signing_in': 'Signing in...',
      'dont_have_an_account': "Don't have an account?",
      'need_help_call_support': 'Need help? Call support: +91 9172272305',
      'choose_your_role': 'Choose Your Role',
      'choose_role_description':
          'Select the type of account that best describes you',
      'labour_role_title': 'Labour',
      'labour_role_description':
          'Find jobs & connect with contractors near you',
      'subcontractor_role_title': 'Sub-Contractor',
      'subcontractor_role_description':
          'Manage your team and take on sub-contracted work',
      'contractor_role_title': 'Contractor',
      'contractor_role_description':
          'Post jobs and hire skilled workers for your projects',
      'use_current_location': 'Use Current Location',
      'fetching_location': 'Fetching Location...',
      'city': 'City *',
      'state': 'State *',
      'city_dropdown': 'City',
      'state_dropdown': 'State',
      'area_dropdown': 'Area',
      'minimum_rating': 'Minimum rating',
      'experience_years': 'Experience (years)',
      'skills': 'Skills',
      'business_types_label': 'Business types',
      'apply_filter': 'Apply filter',
      'clear': 'Clear',
      'advanced_filter': 'Advanced filter',
      'worker_id_card_title': 'Labour ID Card',
      'profession_unknown': 'Profession not specified',
      'available': 'Available',
      'busy': 'Busy',
      'rating_label': 'Rating',
      'contact_label': 'Contact',
      'not_available': 'Not available',
      'search_labour': 'Search labour',
      'search_labour_hint': 'Name, city, or mobile',
      'no_labour_profiles_found': 'No labour profiles found',
      'try_another_search_keyword': 'Try another search keyword.',
      'filter_label': 'Filter',
      'retry': 'Retry',
      'could_not_load_contractors': 'Could not load contractors',
      'could_not_load_labour_list': 'Could not load labour list',
      'subscription_inactive_contractor_masked':
          'Subscription inactive. Contact details are masked. Activate subscription to view full details and use job actions.',
      'subscription_inactive_labour_masked':
          'Subscription inactive. Labour contact details are masked. Activate subscription to unlock full details and apply/create actions.',
      'contractor_profiles': 'Contractor Profiles',
      'search_contractor': 'Search contractor',
      'search_contractor_hint': 'Name, city, or mobile',
      'active_filter': 'Active filter:',
      'filter_city': 'City=',
      'filter_rating': 'Rating≥',
      'filter_experience': 'Experience≥',
      'filter_skills': 'Skills=',
      'filter_business_types': 'Business Types=',
      'no_contractors_found': 'No contractors found',
      'business_profile': 'Business Profile',
      'subscription_required': 'Subscription Required',
      'hidden': 'Hidden',
      'not_specified': 'Not specified',
      'currently_busy': 'Currently busy',
      'labour_profiles': 'Labour Profiles',
      'labour_profile_card_title': 'Labour Profile',
      'view_details': 'View details',
      'availability_label': 'Availability',
      'any': 'Any',
      'pincode': 'Pincode *',
      'address': 'Full Address *',
      'done': 'Done',
      'loading_business_types': 'Loading business types...',
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
      'personal_information': 'Personal Information',
      'business_information': 'Business Information',
      'location': 'Location',
      'documents': 'Documents',
      'terms_and_conditions': 'Terms & Conditions',
      'full_name': 'Full Name',
      'email': 'Email',
      'mobile_number': 'Mobile Number',
      'password': 'Password',
      'business_name': 'Business Name',
      'business_name_hint': 'Your company / firm name',
      'business_name_required': 'Business name is required',
      'owner_manager_name_hint': 'Owner / Manager name',
      'full_name_hint': 'Enter your full name',
      'email_hint': 'name@company.com',
      'email_example_hint': 'name@example.com',
      'mobile_number_hint': 'XXXXX XXXXX',
      'password_hint':
          'Minimum 8 characters with uppercase, lowercase & number',
      'business_reg_number_hint':
          'e.g. 27AAEPM1234C1Z5, AAAPL1234C, or any business registration number',
      'city_hint': 'e.g. Mumbai',
      'state_hint': 'e.g. Maharashtra',
      'pincode_hint': 'e.g. 400001',
      'address_hint': 'Street, Area, Landmark...',
      'house_address_hint': 'House no., Street, Area...',
      'bio_hint': 'Brief description about your work...',
      'experience_range': 'Experience Range *',
      'team_size': 'Team Size *',
      'business_types': 'Business Types *',
      'select_business_types': 'Select Business Types *',
      'choose_business_types': 'Choose all business types that apply',
      'no_business_types_available': 'No business types available',
      'about_your_business': 'About Your Business',
      'full_address': 'Full Address *',
      'business_license': 'Business License / GST / PAN',
      'tap_to_upload_license': 'Tap to upload license, GST, or PAN image',
      'languages': 'Languages',
      'choose_supported_language':
          'Choose a supported language to switch the app labels to Hindi / Marathi / English.',
      'accept_terms_text': 'I accept the Terms & Conditions',
      'select_at_least_one_business_type': 'Select at least one business type',
      'select_at_least_one_language': 'Select at least one language',
      'select_at_least_one_skill': 'Select at least one skill',
      'please_accept_terms': 'Please accept Terms & Conditions',
      'please_wait_files_uploading': 'Please wait — files are still uploading',
      'select_skills': 'Select Skills *',
      'choose_skills': 'Choose multiple skills that match your expertise',
      'no_skills_available': 'No skills available',
      'language_input_hint': 'Tap to select languages',
      'full_name_required': 'Full name is required',
      'email_required': 'Email is required',
      'enter_valid_email': 'Enter valid email',
      'mobile_number_required': 'Mobile number is required',
      'enter_valid_mobile': 'Enter a valid 10-digit mobile number',
      'city_required': 'City is required',
      'state_required': 'State is required',
      'pincode_required': 'Pincode is required',
      'address_required': 'Address is required',
      'password_required': 'Password is required',
      'password_invalid': 'Password does not meet requirements',
      'uploading': 'Uploading...',
      'uploaded': 'Uploaded ✓',
    },
    'hi': {
      'register_as_contractor': 'ठेकेदार के रूप में पंजीकरण',
      'register_as_subcontractor': 'सब-कॉन्ट्रैक्टर के रूप में पंजीकरण',
      'register_as_labour': 'मज़दूर के रूप में पंजीकरण',
      'company_logo_uploaded': 'कंपनी लोगो अपलोड हो गया ✓',
      'tap_to_add_company_logo': 'कंपनी लोगो जोड़ने के लिए टैप करें',
      'date_of_birth': 'जन्मतिथि',
      'account_security': 'खाता सुरक्षा',
      'password_requirements_label': 'पासवर्ड आवश्यकताएँ:',
      'at_least_8_chars': 'कम से कम 8 वर्ण',
      'one_uppercase': 'एक बड़ा अक्षर (A-Z)',
      'one_lowercase': 'एक छोटा अक्षर (a-z)',
      'one_number': 'एक संख्या (0-9)',
      'creating_account': 'खाता बना रहा है...',
      'create_account': 'खाता बनाएं',
      'welcome_back': 'वापसी पर स्वागत है',
      'sign_in_to_your_account': 'अपने खाते में साइन इन करें',
      'email_or_mobile_number': 'ईमेल या मोबाइल नंबर',
      'email_or_mobile_hint': 'name@example.com या +91xxxxxxxxxx',
      'remember_me': 'मुझे याद रखें',
      'forgot_password': 'पासवर्ड भूल गए?',
      'sign_in': 'साइन इन करें',
      'signing_in': 'साइन इन किया जा रहा है...',
      'dont_have_an_account': 'खाता नहीं है?',
      'need_help_call_support': 'मदद चाहिए? सपोर्ट पर कॉल करें: +91 9172272305',
      'choose_your_role': 'अपना रोल चुनें',
      'choose_role_description': 'अपने लिए सबसे उपयुक्त खाता प्रकार चुनें',
      'labour_role_title': 'मज़दूर',
      'labour_role_description':
          'नौकरियाँ खोजें और आसपास के ठेकेदारों से जुड़ें',
      'subcontractor_role_title': 'सब-कॉन्ट्रैक्टर',
      'subcontractor_role_description':
          'अपनी टीम का प्रबंधन करें और सब-कॉन्ट्रैक्टेड काम लें',
      'contractor_role_title': 'ठेकेदार',
      'contractor_role_description':
          'अपना काम पोस्ट करें और अपने प्रोजेक्ट्स के लिए कुशल कारीगरों को काम पर रखें',
      'use_current_location': 'वर्तमान स्थान का उपयोग करें',
      'fetching_location': 'स्थान लाया जा रहा है...',
      'city': 'शहर *',
      'state': 'राज्य *',
      'city_dropdown': 'शहर',
      'state_dropdown': 'राज्य',
      'area_dropdown': 'क्षेत्र',
      'minimum_rating': 'न्यूनतम रेटिंग',
      'experience_years': 'अनुभव (वर्ष)',
      'skills': 'कौशल',
      'business_types_label': 'व्यवसाय प्रकार',
      'apply_filter': 'फ़िल्टर लागू करें',
      'clear': 'साफ़ करें',
      'advanced_filter': 'उन्नत फ़िल्टर',
      'worker_id_card_title': 'मज़दूर आईडी कार्ड',
      'profession_unknown': 'पेशा निर्दिष्ट नहीं',
      'available': 'उपलब्ध',
      'busy': 'व्यस्त',
      'rating_label': 'रेटिंग',
      'contact_label': 'संपर्क',
      'not_available': 'उपलब्ध नहीं',
      'search_labour': 'मज़दूर खोजें',
      'search_labour_hint': 'नाम, शहर, या मोबाइल',
      'no_labour_profiles_found': 'कोई मजदूर प्रोफ़ाइल नहीं मिली',
      'try_another_search_keyword': 'कोई अन्य खोज कीवर्ड आज़माएँ।',
      'filter_label': 'फ़िल्टर',
      'retry': 'पुनः प्रयास करें',
      'could_not_load_contractors': 'ठेकेदार लोड नहीं किए जा सके',
      'could_not_load_labour_list': 'मज़दूर सूची लोड नहीं की जा सकी',
      'subscription_inactive_contractor_masked':
          'सब्सक्रिप्शन निष्क्रिय है। संपर्क विवरण छुपा दिए गए हैं। पूर्ण विवरण देखने और नौकरी क्रियाओं का उपयोग करने के लिए सब्सक्रिप्शन सक्रिय करें।',
      'subscription_inactive_labour_masked':
          'सब्सक्रिप्शन निष्क्रिय है। मजदूर संपर्क विवरण छुपा दिए गए हैं। पूर्ण विवरण और आवेदन/निर्माण क्रियाएं अनलॉक करने के लिए सब्सक्रिप्शन सक्रिय करें।',
      'contractor_profiles': 'ठेकेदार प्रोफ़ाइल',
      'search_contractor': 'ठेकेदार खोजें',
      'search_contractor_hint': 'नाम, शहर, या मोबाइल',
      'active_filter': 'सक्रिय फ़िल्टर:',
      'filter_city': 'शहर=',
      'filter_rating': 'रेटिंग≥',
      'filter_experience': 'अनुभव≥',
      'filter_skills': 'कौशल=',
      'filter_business_types': 'व्यवसाय प्रकार=',
      'no_contractors_found': 'कोई ठेकेदार नहीं मिले',
      'business_profile': 'व्यवसाय प्रोफ़ाइल',
      'subscription_required': 'सब्सक्रिप्शन आवश्यक',
      'hidden': 'छुपा हुआ',
      'not_specified': 'निर्दिष्ट नहीं',
      'currently_busy': 'वर्तमान में व्यस्त',
      'labour_profiles': 'मज़दूर प्रोफ़ाइल',
      'labour_profile_card_title': 'मज़दूर प्रोफ़ाइल',
      'view_details': 'विवरण देखें',
      'availability_label': 'उपलब्धता',
      'any': 'कोई भी',
      'pincode': 'पिनकोड *',
      'address': 'पूरा पता *',
      'done': 'समाप्त',
      'loading_business_types': 'व्यवसाय प्रकार लोड हो रहे हैं...',
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
      'personal_information': 'व्यक्तिगत जानकारी',
      'business_information': 'व्यवसाय की जानकारी',
      'location': 'स्थान',
      'documents': 'दस्तावेज़',
      'terms_and_conditions': 'नियम व शर्तें',
      'full_name': 'पूर्ण नाम',
      'email': 'ईमेल',
      'mobile_number': 'मोबाइल नंबर',
      'password': 'पासवर्ड',
      'business_name': 'व्यवसाय का नाम',
      'business_name_hint': 'आपकी कंपनी / फर्म का नाम',
      'business_name_required': 'व्यवसाय का नाम आवश्यक है',
      'owner_manager_name_hint': 'मालिक / प्रबंधक का नाम',
      'full_name_hint': 'अपना पूरा नाम दर्ज करें',
      'email_hint': 'name@company.com',
      'email_example_hint': 'name@example.com',
      'mobile_number_hint': 'XXXXX XXXXX',
      'password_hint': 'कम से कम 8 वर्ण, बड़े अक्षर, छोटे अक्षर और संख्या',
      'business_reg_number_hint':
          'उदाहरण: 27AAEPM1234C1Z5, AAAPL1234C, या कोई भी व्यवसाय पंजीकरण नंबर',
      'city_hint': 'उदाहरण: मुंबई',
      'state_hint': 'उदाहरण: महाराष्ट्र',
      'pincode_hint': 'उदाहरण: 400001',
      'address_hint': 'स्ट्रीट, एरिया, लैंडमार्क...',
      'house_address_hint': 'मकान नंबर, स्ट्रीट, एरिया...',
      'bio_hint': 'अपने काम के बारे में संक्षिप्त वर्णन...',
      'experience_range': 'अनुभव सीमा *',
      'team_size': 'टीम का आकार *',
      'business_types': 'व्यवसाय प्रकार *',
      'select_business_types': 'व्यवसाय प्रकार चुनें *',
      'choose_business_types':
          'जिन व्यवसाय प्रकारों का लागू होता है उन्हें चुनें',
      'no_business_types_available': 'कोई व्यवसाय प्रकार उपलब्ध नहीं',
      'about_your_business': 'अपने व्यवसाय के बारे में',
      'full_address': 'पूरा पता *',
      'business_license': 'व्यवसाय लाइसेंस / जीएसटी / पैन',
      'tap_to_upload_license':
          'लाइसेंस, जीएसटी, या पैन इमेज अपलोड करने के लिए टैप करें',
      'languages': 'भाषाएँ',
      'choose_supported_language':
          'ऐप लेबल्स को हिन्दी / मराठी / अंग्रेज़ी में बदलने के लिए एक भाषा चुनें.',
      'accept_terms_text': 'मैं नियम व शर्तें स्वीकार करता/करती हूँ',
      'select_at_least_one_business_type': 'कम से कम एक व्यवसाय प्रकार चुनें',
      'select_at_least_one_language': 'कम से कम एक भाषा चुनें',
      'select_at_least_one_skill': 'कम से कम एक कौशल चुनें',
      'please_accept_terms': 'कृपया नियम व शर्तें स्वीकार करें',
      'please_wait_files_uploading':
          'कृपया प्रतीक्षा करें — फाइलें अभी अपलोड हो रही हैं',
      'select_skills': 'कौशल चुनें *',
      'choose_skills': 'अपनी विशेषज्ञता से मिलान करने वाले कई कौशल चुनें',
      'no_skills_available': 'कोई कौशल उपलब्ध नहीं',
      'language_input_hint': 'भाषाएँ चुनने के लिए टैप करें',
      'full_name_required': 'पूरा नाम आवश्यक है',
      'email_required': 'ईमेल आवश्यक है',
      'enter_valid_email': 'मान्य ईमेल दर्ज करें',
      'mobile_number_required': 'मोबाइल नंबर आवश्यक है',
      'enter_valid_mobile': 'मान्य 10-अंकी मोबाइल नंबर दर्ज करें',
      'city_required': 'शहर आवश्यक है',
      'state_required': 'राज्य आवश्यक है',
      'pincode_required': 'पिनकोड आवश्यक है',
      'address_required': 'पता आवश्यक है',
      'password_required': 'पासवर्ड आवश्यक है',
      'password_invalid': 'पासवर्ड आवश्यकताओं को पूरा नहीं करता',
      'uploading': 'अपलोड हो रहा है...',
      'uploaded': 'अपलोड किया गया ✓',
    },
    'mr': {
      'register_as_contractor': 'ठेकेदार म्हणून नोंदणी',
      'register_as_subcontractor': 'सब-कॉन्ट्रॅक्टर म्हणून नोंदणी',
      'register_as_labour': 'कामगार म्हणून नोंदणी',
      'company_logo_uploaded': 'कंपनी लोगो अपलोड झाले ✓',
      'tap_to_add_company_logo': 'कंपनी लोगो जोडण्यासाठी टॅप करा',
      'date_of_birth': 'जन्म तारीख',
      'account_security': 'खाते सुरक्षा',
      'password_requirements_label': 'पासवर्ड आवश्यकता:',
      'at_least_8_chars': 'किमान 8 वर्ण',
      'one_uppercase': 'एक मोठा अक्षर (A-Z)',
      'one_lowercase': 'एक लहान अक्षर (a-z)',
      'one_number': 'एक अंक (0-9)',
      'creating_account': 'खाते तयार करीत आहे...',
      'create_account': 'खाता तयार करा',
      'welcome_back': 'परत स्वागत आहे',
      'sign_in_to_your_account': 'आपल्या खात्यात साइन इन करा',
      'email_or_mobile_number': 'ईमेल किंवा मोबाइल नंबर',
      'email_or_mobile_hint': 'name@example.com किंवा +91xxxxxxxxxx',
      'remember_me': 'मला आठवा',
      'forgot_password': 'पासवर्ड विसरलात?',
      'sign_in': 'साइन इन करा',
      'signing_in': 'साइन इन केला जात आहे...',
      'dont_have_an_account': 'खाते नाही का?',
      'need_help_call_support':
          'मदतीची गरज आहे? समर्थनाला कॉल करा: +91 9172272305',
      'choose_your_role': 'आपला रोल निवडा',
      'choose_role_description': 'तुमच्यासाठी सर्वोत्तम खाते प्रकार निवडा',
      'labour_role_title': 'कामगार',
      'labour_role_description':
          'जॉब शोधा आणि तुमच्या आसपासच्या कॉन्ट्रॅक्टरशी संपर्क साधा',
      'subcontractor_role_title': 'सब-ठेकेदार',
      'subcontractor_role_description':
          'आपल्या टीमचे व्यवस्थापन करा आणि सब-कॉन्ट्रॅक्ट काम घ्या',
      'contractor_role_title': 'ठेकेदार',
      'contractor_role_description':
          'आपले प्रकल्प पोस्ट करा आणि कुशल कामगारांची नेमणूक करा',
      'use_current_location': 'सध्याचे स्थान वापरा',
      'fetching_location': 'स्थान मिळवत आहे...',
      'city': 'शहर *',
      'state': 'राज्य *',
      'city_dropdown': 'शहर',
      'state_dropdown': 'राज्य',
      'minimum_rating': 'किमान रेटिंग',
      'experience_years': 'अनुभव (वर्ष)',
      'skills': 'कौशल्ये',
      'business_types_label': 'व्यवसाय प्रकार',
      'apply_filter': 'फिल्टर लागू करा',
      'clear': 'क्लिअर',
      'advanced_filter': 'प्रगत फिल्टर',
      'worker_id_card_title': 'मजूर आयडी कार्ड',
      'profession_unknown': 'व्यवसाय निर्दिष्ट केलेला नाही',
      'available': 'उपलब्ध',
      'busy': 'व्यस्त',
      'rating_label': 'रेटिंग',
      'contact_label': 'संपर्क',
      'not_available': 'उपलब्ध नाही',
      'search_labour': 'मजूर शोधा',
      'search_labour_hint': 'नाव, शहर किंवा मोबाइल',
      'no_labour_profiles_found': 'कोणतीही मजूर प्रोफाइल आढळली नाही',
      'try_another_search_keyword': 'इतर शोध कीवर्ड वापरून पहा.',
      'filter_label': 'फिल्टर',
      'retry': 'पुन्हा प्रयत्न करा',
      'could_not_load_contractors': 'ठेकेदार लोड करता आले नाहीत',
      'could_not_load_labour_list': 'कामगार यादी लोड करता आली नाही',
      'subscription_inactive_contractor_masked':
          'सदस्यता निष्क्रीय आहे. संपर्क तपशील लपवण्यात आले आहेत. पूर्ण तपशील पाहण्यासाठी आणि नोकरी क्रिया वापरण्यासाठी सदस्यता सक्रिय करा.',
      'subscription_inactive_labour_masked':
          'सदस्यता निष्क्रीय आहे. कामगार संपर्क तपशील लपवण्यात आले आहेत. पूर्ण तपशील आणि अर्ज/निर्माण क्रिया अनलॉक करण्यासाठी सदस्यता सक्रिय करा.',
      'contractor_profiles': 'ठेकेदार प्रोफाइल',
      'search_contractor': 'ठेकेदार शोधा',
      'search_contractor_hint': 'नाव, शहर किंवा मोबाइल',
      'active_filter': 'सक्रिय फिल्टर:',
      'filter_city': 'शहर=',
      'filter_rating': 'रेटिंग≥',
      'filter_experience': 'अनुभव≥',
      'filter_skills': 'कौशल्ये=',
      'filter_business_types': 'व्यवसाय प्रकार=',
      'no_contractors_found': 'कोणतेही ठेकेदार सापडले नाहीत',
      'business_profile': 'व्यवसाय प्रोफाइल',
      'subscription_required': 'सदस्यता आवश्यक',
      'hidden': 'लपवलेले',
      'not_specified': 'निर्दिष्ट नाही',
      'currently_busy': 'सध्या व्यस्त',
      'labour_profiles': 'कामगार प्रोफाइल',
      'labour_profile_card_title': 'कामगार प्रोफाइल',
      'view_details': 'तपशील पहा',
      'availability_label': 'उपलब्धता',
      'any': 'कोणतेही',
      'pincode': 'पिनकोड *',
      'address': 'पूर्ण पत्ता *',
      'done': 'पूर्ण',
      'loading_business_types': 'व्यवसाय प्रकार लोड करत आहोत...',
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
      'personal_information': 'वैयक्तिक माहिती',
      'business_information': 'व्यवसायाची माहिती',
      'location': 'ठिकाण',
      'documents': 'दस्तऐवज',
      'terms_and_conditions': 'नियम व अटी',
      'full_name': 'पूर्ण नाव',
      'email': 'ईमेल',
      'mobile_number': 'मोबाइल नंबर',
      'password': 'पासवर्ड',
      'business_name': 'व्यवसायाचे नाव',
      'business_name_hint': 'आपली कंपनी / फर्म चे नाव',
      'business_name_required': 'व्यवसायाचे नाव आवश्यक आहे',
      'owner_manager_name_hint': 'मालक / व्यवस्थापक नाव',
      'full_name_hint': 'आपले पूर्ण नाव प्रविष्ट करा',
      'email_hint': 'name@company.com',
      'email_example_hint': 'name@example.com',
      'mobile_number_hint': 'XXXXX XXXXX',
      'password_hint':
          'किमान 8 वर्ण, मोठ्या आणि लहान अक्षरे आणि संख्या असणे आवश्यक आहे',
      'business_reg_number': 'व्यवसाय नोंदणी / GST / PAN क्रमांक',
      'business_reg_number_hint':
          'उदा. 27AAEPM1234C1Z5, AAAPL1234C, किंवा कोणताही व्यवसाय नोंदणी क्रमांक',
      'city_hint': 'उदा. मुंबई',
      'state_hint': 'उदा. महाराष्ट्र',
      'pincode_hint': 'उदा. 400001',
      'address_hint': 'स्ट्रीट, एरिया, लँडमार्क...',
      'house_address_hint': 'घर क्रमांक, गल्ला, क्षेत्र...',
      'bio_hint': 'आपल्या कामाबद्दल संक्षिप्त वर्णन...',
      'about_yourself': 'तुमच्या बद्दल',
      'experience_range': 'अनुभव श्रेणी *',
      'team_size': 'संघ आकार *',
      'business_types': 'व्यवसाय प्रकार *',
      'select_business_types': 'व्यवसाय प्रकार निवडा *',
      'choose_business_types': 'ज्या व्यवसाय प्रकारांना लागू आहे ते निवडा',
      'no_business_types_available': 'कोणतेही व्यवसाय प्रकार उपलब्ध नाहीत',
      'about_your_business': 'आपल्या व्यवसायाबद्दल',
      'full_address': 'पूर्ण पत्ता *',
      'business_license': 'व्यवसाय परवाना / GST / PAN',
      'tap_to_upload_license':
          'परवाना, GST किंवा PAN इमेज अपलोड करण्यासाठी टॅप करा',
      'languages': 'भाषा',
      'choose_supported_language':
          'अॅप लेबल हिंदी / मराठी / इंग्रजी मध्ये बदलण्यासाठी भाषा निवडा.',
      'accept_terms_text': 'मी नियम व अटी स्वीकारतो/स्वीकारते',
      'select_at_least_one_business_type': 'किमान एक व्यवसाय प्रकार निवडा',
      'select_at_least_one_language': 'किमान एक भाषा निवडा',
      'select_at_least_one_skill': 'किमान एक कौशल्य निवडा',
      'please_accept_terms': 'कृपया नियम व अटी स्वीकारा',
      'please_wait_files_uploading':
          'कृपया प्रतीक्षा करा — फाइल्स अपलोड होत आहेत',
      'select_skills': 'कौशल्ये निवडा *',
      'choose_skills': 'आपल्या कौशल्यांशी जुळणारी अनेक कौशल्ये निवडा',
      'no_skills_available': 'कोणतीही कौशल्ये उपलब्ध नाहीत',
      'language_input_hint': 'भाषा निवडण्यासाठी टॅप करा',
      'full_name_required': 'पूर्ण नाव आवश्यक आहे',
      'email_required': 'ईमेल आवश्यक आहे',
      'enter_valid_email': 'वैध ईमेल टाइप करा',
      'mobile_number_required': 'मोबाइल नंबर आवश्यक आहे',
      'enter_valid_mobile': 'वैध 10-अंकी मोबाइल नंबर टाइप करा',
      'city_required': 'शहर आवश्यक आहे',
      'state_required': 'राज्य आवश्यक आहे',
      'pincode_required': 'पिनकोड आवश्यक आहे',
      'address_required': 'पत्ता आवश्यक आहे',
      'password_required': 'पासवर्ड आवश्यक आहे',
      'password_invalid': 'पासवर्ड आवश्यकतांना पूर्ण करत नाही',
      'uploading': 'अपलोड करत आहे...',
      'uploaded': 'अपलोड झाले ✓',
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
  String get fullNameRequired => _t('full_name_required');
  String get emailRequired => _t('email_required');
  String get enterValidEmail => _t('enter_valid_email');
  String get mobileNumberRequired => _t('mobile_number_required');
  String get enterValidMobile => _t('enter_valid_mobile');
  String get passwordRequired => _t('password_required');
  String get passwordInvalid => _t('password_invalid');
  String get cityRequired => _t('city_required');
  String get stateRequired => _t('state_required');
  String get pincodeRequired => _t('pincode_required');
  String get addressRequired => _t('address_required');
  String get uploading => _t('uploading');
  String get uploaded => _t('uploaded');
  String get registerAsContractor => _t('register_as_contractor');
  String get registerAsSubcontractor => _t('register_as_subcontractor');
  String get registerAsLabour => _t('register_as_labour');
  String get companyLogoUploaded => _t('company_logo_uploaded');
  String get tapToAddCompanyLogo => _t('tap_to_add_company_logo');
  String get dateOfBirth => _t('date_of_birth');
  String get accountSecurity => _t('account_security');
  String get passwordRequirementsLabel => _t('password_requirements_label');
  String get atLeast8Chars => _t('at_least_8_chars');
  String get oneUppercase => _t('one_uppercase');
  String get oneLowercase => _t('one_lowercase');
  String get oneNumber => _t('one_number');
  String get creatingAccount => _t('creating_account');
  String get createAccount => _t('create_account');
  String get welcomeBack => _t('welcome_back');
  String get signInToYourAccount => _t('sign_in_to_your_account');
  String get emailOrMobileNumber => _t('email_or_mobile_number');
  String get emailOrMobileHint => _t('email_or_mobile_hint');
  String get rememberMe => _t('remember_me');
  String get forgotPassword => _t('forgot_password');
  String get signIn => _t('sign_in');
  String get signingIn => _t('signing_in');
  String get dontHaveAnAccount => _t('dont_have_an_account');
  String get needHelpCallSupport => _t('need_help_call_support');
  String get chooseYourRole => _t('choose_your_role');
  String get chooseRoleDescription => _t('choose_role_description');
  String get labourRoleTitle => _t('labour_role_title');
  String get labourRoleDescription => _t('labour_role_description');
  String get subcontractorRoleTitle => _t('subcontractor_role_title');
  String get subcontractorRoleDescription =>
      _t('subcontractor_role_description');
  String get contractorRoleTitle => _t('contractor_role_title');
  String get contractorRoleDescription => _t('contractor_role_description');
  String get useCurrentLocation => _t('use_current_location');
  String get fetchingLocation => _t('fetching_location');
  String get cityLabel => _t('city');
  String get stateLabel => _t('state');
  String get cityLabelDropdown => _t('city_dropdown');
  String get stateLabelDropdown => _t('state_dropdown');
  String get areaLabelDropdown => _t('area_dropdown');
  String get workerIdCardTitle => _t('worker_id_card_title');
  String get professionUnknown => _t('profession_unknown');
  String get available => _t('available');
  String get busy => _t('busy');
  String get ratingLabel => _t('rating_label');
  String get contactLabel => _t('contact_label');
  String get notAvailable => _t('not_available');
  String get searchLabour => _t('search_labour');
  String get searchLabourHint => _t('search_labour_hint');
  String get noLabourProfilesFound => _t('no_labour_profiles_found');
  String get tryAnotherSearchKeyword => _t('try_another_search_keyword');
  String get filterLabel => _t('filter_label');
  String get filterCity => _t('filter_city');
  String get filterRating => _t('filter_rating');
  String get filterExperience => _t('filter_experience');
  String get filterSkills => _t('filter_skills');
  String get filterBusinessTypes => _t('filter_business_types');
  String get labourProfiles => _t('labour_profiles');
  String get labourProfileCardTitle => _t('labour_profile_card_title');
  String get viewDetails => _t('view_details');
  String get availabilityLabel => _t('availability_label');
  String get retry => _t('retry');
  String get couldNotLoadContractors => _t('could_not_load_contractors');
  String get couldNotLoadLabourList => _t('could_not_load_labour_list');
  String get subscriptionInactiveContractorMasked =>
      _t('subscription_inactive_contractor_masked');
  String get subscriptionInactiveLabourMasked =>
      _t('subscription_inactive_labour_masked');
  String get contractorProfiles => _t('contractor_profiles');
  String get searchContractor => _t('search_contractor');
  String get searchContractorHint => _t('search_contractor_hint');
  String get activeFilterLabel => _t('active_filter');
  String get noContractorsFound => _t('no_contractors_found');
  String get businessProfile => _t('business_profile');
  String get subscriptionRequired => _t('subscription_required');
  String get hidden => _t('hidden');
  String get notSpecified => _t('not_specified');
  String get currentlyBusy => _t('currently_busy');
  String get minimumRatingLabel => _t('minimum_rating');
  String get experienceYearsLabel => _t('experience_years');
  String get skillsLabel => _t('skills');
  String get businessTypesLabel => _t('business_types_label');
  String get applyFilterButtonLabel => _t('apply_filter');
  String get clearLabel => _t('clear');
  String get advancedFilterLabel => _t('advanced_filter');
  String get anyLabel => _t('any');
  String get pincodeLabel => _t('pincode');
  String get addressLabel => _t('address');
  String get done => _t('done');
  String get loadingBusinessTypes => _t('loading_business_types');
  String get personalInformation => _t('personal_information');
  String get businessInformation => _t('business_information');
  String get locationSection => _t('location');
  String get documents => _t('documents');
  String get termsAndConditions => _t('terms_and_conditions');
  String get fullName => _t('full_name');
  String get email => _t('email');
  String get mobileNumber => _t('mobile_number');
  String get password => _t('password');
  String get businessName => _t('business_name');
  String get businessNameHint => _t('business_name_hint');
  String get businessNameRequired => _t('business_name_required');
  String get ownerManagerNameHint => _t('owner_manager_name_hint');
  String get fullNameHint => _t('full_name_hint');
  String get emailHint => _t('email_hint');
  String get emailExampleHint => _t('email_example_hint');
  String get mobileNumberHint => _t('mobile_number_hint');
  String get passwordHint => _t('password_hint');
  String get businessRegNumber => _t('business_reg_number');
  String get businessRegNumberHint => _t('business_reg_number_hint');
  String get cityHint => _t('city_hint');
  String get stateHint => _t('state_hint');
  String get pincodeHint => _t('pincode_hint');
  String get addressHint => _t('address_hint');
  String get houseAddressHint => _t('house_address_hint');
  String get bioHint => _t('bio_hint');
  String get aboutYourself => _t('about_yourself');
  String get experienceRange => _t('experience_range');
  String get teamSize => _t('team_size');
  String get businessTypes => _t('business_types');
  String get selectBusinessTypes => _t('select_business_types');
  String get chooseBusinessTypes => _t('choose_business_types');
  String get noBusinessTypesAvailable => _t('no_business_types_available');
  String get aboutYourBusiness => _t('about_your_business');
  String get fullAddress => _t('full_address');
  String get businessLicense => _t('business_license');
  String get tapToUploadLicense => _t('tap_to_upload_license');
  String get languages => _t('languages');
  String get chooseSupportedLanguage => _t('choose_supported_language');
  String get acceptTermsText => _t('accept_terms_text');
  String get selectAtLeastOneBusinessType =>
      _t('select_at_least_one_business_type');
  String get selectAtLeastOneLanguage => _t('select_at_least_one_language');
  String get selectAtLeastOneSkill => _t('select_at_least_one_skill');
  String get pleaseAcceptTerms => _t('please_accept_terms');
  String get pleaseWaitFilesUploading => _t('please_wait_files_uploading');
  String get selectSkills => _t('select_skills');
  String get chooseSkills => _t('choose_skills');
  String get noSkillsAvailable => _t('no_skills_available');
  String get languageInputHint => _t('language_input_hint');
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
