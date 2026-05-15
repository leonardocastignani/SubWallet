import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _currency = '€';
  String _language = 'Italiano';

  String get currency => _currency;
  String get language => _language;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? '€';
    _language = prefs.getString('language') ?? 'Italiano';
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    _currency = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    _language = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
    notifyListeners();
  }

  // --- DIZIONARIO GLOBALE DELL'APP ---
  final Map<String, Map<String, String>> _dict = {
    'Italiano': {
      // MENU E STATISTICHE
      'tab_stats': 'Statistiche', 'tab_home': 'Home', 'tab_settings': 'Impostazioni',
      'monthly_spend': 'Spesa mensile', 'annual_spend': 'Spesa annuale',
      'active_subs': 'N° abbonamenti', 'avg_cost': 'Costo medio',
      'vs_last_month': 'vs mese scorso', 'projected': 'proiettata',
      'active_now': 'attivi ora', 'per_sub_month': 'per abbonamento/mese',
      'details': 'DETTAGLI', 'cat_title': 'Spesa per categoria', 'cat_sub': 'Streaming, produttività, gaming, news',
      'trend_title': 'Andamento nel tempo', 'trend_sub': 'Grafico a linee degli ultimi 6 mesi',
      'cal_title': 'Calendario pagamenti', 'cal_sub': 'Visualizzazione di quando escono i soldi',
      'rank_title': 'Classifica per costo', 'rank_sub': 'Dal più caro al più economico',
      'ai_title': 'Insight intelligenti (AI)', 'ai_sub': 'Analisi automatica e consigli di risparmio',
      'no_subs': 'Nessun abbonamento', 'no_subs_desc': 'Aggiungi il tuo primo abbonamento\nper iniziare a tracciarlo.',
      'deleted': 'eliminato', 'unknown': 'Sconosciuto',
      // IMPOSTAZIONI
      'sec_account': 'ACCOUNT', 'sec_notif': 'NOTIFICHE', 'sec_data': 'DATI', 'sec_appearance': 'ASPETTO', 'sec_privacy': 'PRIVACY',
      'profile': 'Profilo', 'profile_sub': 'Accedi per gestire i tuoi dati',
      'cur_lang': 'Valuta e lingua', 'cur_lang_sub': '€ · \$ · £ e localizzazione',
      'reminders': 'Promemoria rinnovo', 'reminders_sub': 'Avvisa 1/3/7 giorni prima',
      'report': 'Report mensile', 'report_sub': 'Riepilogo spese all\'inizio del mese',
      'budget': 'Soglia di budget', 'budget_sub': 'Notifica se superi una soglia',
      'import_export': 'Importa / Esporta', 'import_export_sub': 'CSV o JSON · backup manuale',
      'cloud_sync': 'Sync cloud', 'cloud_sync_sub': 'Salvataggio automatico su database',
      'multi_dev': 'Multi-dispositivo', 'multi_dev_sub': 'Gestione sessioni attive',
      'theme': 'Tema', 'theme_sub': 'Chiaro · scuro · sistema',
      'def_view': 'Visualizzazione default', 'def_view_sub': 'Lista · griglia · raggruppata',
      'app_lock': 'Blocco app', 'app_lock_sub': 'Face ID / Impronta / PIN',
      'priv_mode': 'Modalità privata', 'priv_mode_sub': 'Nasconde importi nelle schermate',
      'logout': 'Disconnetti',
      'cur_lang_title': 'Valuta e Lingua', 'cur_header': 'VALUTA PREDEFINITA', 'lang_header': 'LINGUA DELL\'APP',
      'cur_note': 'Nota: La modifica della valuta aggiornerà il simbolo in tutta l\'app in tempo reale.',
      // MODALI E AGGIUNTA
      'total': 'Totale', 'monthly_detail': 'DETTAGLIO MENSILE', 'per_month': '/mese',
      'last_6_months': 'Ultimi 6 mesi', 'current_monthly_spend': 'Spesa mensile attuale',
      'next_30_days': 'Prossimi 30 giorni', 'payments_soon': 'pagamenti in uscita a breve',
      'timeline_title': 'TIMELINE', 'no_payments': 'Nessun pagamento in programma.',
      'wallet_impact': 'Impatto sul portafoglio', 'subs_analyzed': 'abbonamenti analizzati',
      'expensive_to_cheap': 'DAL PIÙ CARO AL PIÙ ECONOMICO', 'no_subs_rank': 'Nessun abbonamento da classificare.',
      'select_service': 'Seleziona servizio', 'custom_service': 'Crea personalizzato', 'custom_service_sub': 'Aggiungi un servizio non in lista',
      'sub_details': 'Dettagli Abbonamento', 'name_placeholder': 'Nome (es. Palestra)',
      'cost': 'Costo', 'cycle': 'Ciclo', 'monthly': 'Mensile', 'annual': 'Annuale',
      'category': 'Categoria', 'payment': 'Pagamento', 'next_renewal': 'Prossimo rinnovo',
      'notes': 'Note', 'additional_details': 'Dettagli aggiuntivi...', 'cancel': 'Annulla', 'save': 'Salva', 'added': 'aggiunto!',
      // LOGIN E PROFILO
      'login_subtitle': 'Tieni sotto controllo i tuoi\nabbonamenti in un unico posto.',
      'continue_google': 'Continua con Google', 'continue_apple': 'Continua con Apple', 'apple_coming_soon': 'Login con Apple in arrivo!',
      'public_info': 'INFORMAZIONI PUBBLICHE', 'name_label': 'Nome', 'insert_name': 'Inserisci nome',
      'security': 'SICUREZZA', 'email': 'Email', 'back': 'Indietro',
      'profile_desc': 'Clicca sulla foto per modificarla. I dati del tuo profilo vengono utilizzati per personalizzare la tua esperienza su SubWallet.',
      'profile_updated': 'Profilo aggiornato! ✅', 'update_error': 'Errore nell\'aggiornamento.', 'gallery_error': 'Errore nell\'apertura della galleria',
    },
    'English': {
      // MENU E STATISTICHE
      'tab_stats': 'Statistics', 'tab_home': 'Home', 'tab_settings': 'Settings',
      'monthly_spend': 'Monthly Spend', 'annual_spend': 'Annual Spend',
      'active_subs': 'Active Subs', 'avg_cost': 'Avg Cost',
      'vs_last_month': 'vs last month', 'projected': 'projected', 
      'active_now': 'active now', 'per_sub_month': 'per sub/month',
      'details': 'DETAILS', 'cat_title': 'Spend by Category', 'cat_sub': 'Streaming, productivity, gaming, news',
      'trend_title': 'Trend over time', 'trend_sub': 'Line chart of the last 6 months',
      'cal_title': 'Payment Calendar', 'cal_sub': 'Visual timeline of outgoing money',
      'rank_title': 'Cost Ranking', 'rank_sub': 'From most to least expensive',
      'ai_title': 'Smart Insights (AI)', 'ai_sub': 'Automatic analysis and savings tips',
      'no_subs': 'No subscriptions', 'no_subs_desc': 'Add your first subscription\nto start tracking it.',
      'deleted': 'deleted', 'unknown': 'Unknown',
      // IMPOSTAZIONI
      'sec_account': 'ACCOUNT', 'sec_notif': 'NOTIFICATIONS', 'sec_data': 'DATA', 'sec_appearance': 'APPEARANCE', 'sec_privacy': 'PRIVACY',
      'profile': 'Profile', 'profile_sub': 'Log in to manage your data',
      'cur_lang': 'Currency & Language', 'cur_lang_sub': '€ · \$ · £ and localization',
      'reminders': 'Renewal reminders', 'reminders_sub': 'Alert 1/3/7 days before',
      'report': 'Monthly report', 'report_sub': 'Expense summary at start of month',
      'budget': 'Budget threshold', 'budget_sub': 'Notify if spending exceeds a limit',
      'import_export': 'Import / Export', 'import_export_sub': 'CSV or JSON · manual backup',
      'cloud_sync': 'Cloud sync', 'cloud_sync_sub': 'Automatic save to database',
      'multi_dev': 'Multi-device', 'multi_dev_sub': 'Manage active sessions',
      'theme': 'Theme', 'theme_sub': 'Light · dark · system',
      'def_view': 'Default view', 'def_view_sub': 'List · grid · grouped',
      'app_lock': 'App lock', 'app_lock_sub': 'Face ID / Fingerprint / PIN',
      'priv_mode': 'Private mode', 'priv_mode_sub': 'Hides amounts on screens',
      'logout': 'Sign Out',
      'cur_lang_title': 'Currency & Language', 'cur_header': 'DEFAULT CURRENCY', 'lang_header': 'APP LANGUAGE',
      'cur_note': 'Note: Changing the currency will update the symbol across the app in real time.',
      // MODALI E AGGIUNTA
      'total': 'Total', 'monthly_detail': 'MONTHLY DETAIL', 'per_month': '/month',
      'last_6_months': 'Last 6 months', 'current_monthly_spend': 'Current monthly spend',
      'next_30_days': 'Next 30 days', 'payments_soon': 'upcoming payments',
      'timeline_title': 'TIMELINE', 'no_payments': 'No upcoming payments.',
      'wallet_impact': 'Wallet impact', 'subs_analyzed': 'subscriptions analyzed',
      'expensive_to_cheap': 'MOST TO LEAST EXPENSIVE', 'no_subs_rank': 'No subscriptions to rank.',
      'select_service': 'Select service', 'custom_service': 'Create custom', 'custom_service_sub': 'Add a service not listed',
      'sub_details': 'Subscription Details', 'name_placeholder': 'Name (e.g., Gym)',
      'cost': 'Cost', 'cycle': 'Cycle', 'monthly': 'Monthly', 'annual': 'Annual',
      'category': 'Category', 'payment': 'Payment', 'next_renewal': 'Next renewal',
      'notes': 'Notes', 'additional_details': 'Additional details...', 'cancel': 'Cancel', 'save': 'Save', 'added': 'added!',
      // LOGIN E PROFILO
      'login_subtitle': 'Keep track of your\nsubscriptions in one place.',
      'continue_google': 'Continue with Google', 'continue_apple': 'Continue with Apple', 'apple_coming_soon': 'Apple login coming soon!',
      'public_info': 'PUBLIC INFORMATION', 'name_label': 'Name', 'insert_name': 'Enter name',
      'security': 'SECURITY', 'email': 'Email', 'back': 'Back',
      'profile_desc': 'Tap the photo to change it. Your profile data is used to personalize your experience on SubWallet.',
      'profile_updated': 'Profile updated! ✅', 'update_error': 'Update error.', 'gallery_error': 'Error opening gallery',
    }
  };

  String t(String key) => _dict[_language]?[key] ?? key;

  String tCat(String category) {
    if (_language == 'English') {
      switch(category) {
        case 'Intrattenimento': return 'Entertainment';
        case 'Produttività': return 'Productivity';
        case 'Informazione': return 'Information';
        case 'Salute e Sport': return 'Health & Sport';
        case 'Altro': return 'Other';
      }
    }
    return category;
  }

  String tPay(String method) {
    if (_language == 'English') {
      switch(method) {
        case 'Carta di Credito': return 'Credit Card';
        case 'Bonifico': return 'Bank Transfer';
        case 'Postepay': return 'Postepay';
        case 'Altro': return 'Other';
      }
    }
    return method;
  }

  String tMonthShort(int month) {
    const it = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return _language == 'English' ? en[month - 1] : it[month - 1];
  }

  String tCycle(String cycle) {
    if (_language == 'English') return cycle == 'Mensile' ? 'Monthly' : 'Annual';
    return cycle;
  }
}