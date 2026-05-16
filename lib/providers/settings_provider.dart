import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  int _reminderDays = 3;

  int get reminderDays => _reminderDays;
  
  String get currency => '€';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderDays = prefs.getInt('reminderDays') ?? 3;
    notifyListeners();
  }

  Future<void> setReminderDays(int days) async {
    _reminderDays = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderDays', days);
    notifyListeners();
  }

  final Map<String, String> _dict = {
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
    'reminders_title': 'Promemoria Rinnovo', 'alert_before': 'AVVISA PRIMA DELLA SCADENZA',
    'day_1': '1 giorno prima', 'days_3': '3 giorni prima', 'days_7': '7 giorni prima', 'none': 'Nessuno',
    'reminders_note': 'Riceverai una notifica push locale per ricordarti dei pagamenti imminenti. Assicurati di aver concesso i permessi.',
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
    'login_subtitle': 'Tieni sotto controllo i tuoi\nabbonamenti in un unico posto.',
    'continue_google': 'Continua con Google', 'continue_apple': 'Continua con Apple', 'apple_coming_soon': 'Login con Apple in arrivo!',
    'public_info': 'INFORMAZIONI PUBBLICHE', 'name_label': 'Nome', 'insert_name': 'Inserisci nome',
    'security': 'SICUREZZA', 'email': 'Email', 'back': 'Indietro',
    'profile_desc': 'I dati del tuo profilo sono sincronizzati con il tuo account Google e vengono utilizzati per personalizzare la tua esperienza su SubWallet. Puoi modificare il tuo nome e la tua foto del profilo, ma l\'email è protetta per motivi di sicurezza.',
    'profile_updated': 'Profilo aggiornato! ✅', 'update_error': 'Errore nell\'aggiornamento.', 'gallery_error': 'Errore nell\'apertura della galleria',
  };

  String t(String key) => _dict[key] ?? key;

  String tCat(String category) => category;
  String tPay(String method) => method;
  String tCycle(String cycle) => cycle;

  String tMonthShort(int month) {
    const it = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    return it[month - 1];
  }
}