# 💳📲 SubWallet

SubWallet è un'applicazione sviluppata in Flutter progettata per semplificare la gestione, il tracciamento e il monitoraggio dei tuoi abbonamenti e delle spese ricorrenti.

## ✨ Funzionalità Principali

*   **Autenticazione Sicura**: Accesso rapido e sicuro tramite Firebase (supporto per Google Sign-In).
*   **Sincronizzazione in Cloud**: I dati dei tuoi abbonamenti sono salvati in tempo reale tramite Cloud Firestore, rendendoli accessibili e sincronizzati su tutti i tuoi dispositivi.
*   **Notifiche e Promemoria**: Non perdere più una scadenza! Ricevi notifiche locali puntuali prima del rinnovo di un abbonamento.
*   **Gestione Documenti e Immagini**: Carica ricevute, loghi o immagini personalizzate legate ai tuoi abbonamenti direttamente su Firebase Storage.
*   **Cross-Platform**: Supporto completo per dispositivi mobili (Android, iOS) e predisposizione Web.

## 🛠️ Architettura e Tecnologie

Questo progetto si basa su moderne tecnologie di sviluppo per garantire performance ottimali e codice scalabile:

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Backend as a Service (BaaS)**: Firebase
    *   Firebase Auth & Google Sign-In
    *   Cloud Firestore (Database NoSQL)
    *   Firebase Storage
*   **Architettura e Gestione Stato**:
    *   `provider`: Per la gestione reattiva dello stato dell'applicazione.
*   **Librerie e Plugin Essenziali**:
    *   `fl_chart`: Per la visualizzazione grafica delle spese e dei dati tramite grafici interattivi.
    *   `flutter_local_notifications` e `flutter_timezone`: Per le notifiche push locali basate su fuso orario.
    *   `flutter_dotenv`: Per la gestione sicura di variabili d'ambiente tramite file `.env`.
    *   `shared_preferences`: Per il salvataggio di impostazioni e dati di sessione in locale.
    *   `image_picker`: Per l'accesso ottimizzato alla fotocamera e galleria.
    *   `fluttertoast`: Per i feedback UI istantanei.

## 🚀 Come iniziare (Sviluppo Locale)

Vuoi compilare o estendere il progetto localmente? Segui questi step:

### Prerequisiti

*   Flutter SDK (aggiornato)
*   Dart SDK
*   Emulatore Android/iOS o un dispositivo fisico

### Setup dell'ambiente

1. Clona/Scarica questo repository.
2. Posizionati nella directory del progetto ed esegui il fetch dei pacchetti:
   ```bash
   flutter pub get
   ```
3. Crea un file `.env` nella root del progetto per le tue variabili d'ambiente (segui le configurazioni previste dal pacchetto `flutter_dotenv`).
4. Il file `firebase_options.dart` e `google-services.json` sono già integrati per puntare al progetto backend, tuttavia se intendi utilizzare un tuo progetto Firebase, aggiornali tramite [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).
5. Avvia l'applicazione in modalità debug:
   ```bash
   flutter run
   ```

## 📁 Struttura del Progetto

Il codice applicativo si trova principalmente sotto la directory `lib/`:
*   `lib/screens/`: Contiene le viste/schermate principali dell'app (es. Dashboard, Login, Aggiunta di un servizio).
*   `lib/services/`: Logica di business e connettività, incluse chiamate a Firebase, logiche di notifica e cloud.
*   `lib/widgets/`: Componenti dell'interfaccia utente atomici e riutilizzabili su più schermi.
*   `main.dart` e `firebase_options.dart`: Entry point per l'inizializzazione del progetto e configurazione di backend.

---
*Progetto creato e mantenuto con ❤️ tramite Flutter.*