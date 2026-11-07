import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService {
  AppStateService._();

  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('English');

  static bool get isLight => themeModeNotifier.value == ThemeMode.light;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('pref_appearance') ?? 'Dark';
      if (savedTheme == 'Light') {
        themeModeNotifier.value = ThemeMode.light;
      } else if (savedTheme == 'System') {
        themeModeNotifier.value = ThemeMode.system;
      } else {
        themeModeNotifier.value = ThemeMode.dark;
      }

      final savedLang = prefs.getString('pref_language') ?? 'English';
      languageNotifier.value = savedLang;
    } catch (_) {}
  }

  static Future<void> setAppearance(String appearance) async {
    if (appearance == 'Light') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (appearance == 'System') {
      themeModeNotifier.value = ThemeMode.system;
    } else {
      themeModeNotifier.value = ThemeMode.dark;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_appearance', appearance);
    } catch (_) {}
  }

  static Future<void> setLanguage(String language) async {
    languageNotifier.value = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_language', language);
    } catch (_) {}
  }

  // Multi-language translation lookup
  static String tr(String key) {
    final lang = languageNotifier.value;
    final dict = _translations[lang] ?? _translations['English']!;
    return dict[key] ?? _translations['English']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'English': {
      'settings': 'Settings',
      'account_settings': 'Account Settings',
      'personal_information': 'Personal Information',
      'password_security': 'Password & Security',
      'social_accounts': 'Social Accounts',
      'delete_account': 'Delete Account',
      'preferences': 'Preferences',
      'notification_settings': 'Notification Settings',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'sms_alerts': 'SMS Alerts',
      'privacy_data': 'Privacy & Data',
      'language': 'Language',
      'appearance': 'Appearance',
      'app_settings': 'App Settings',
      'storage_cache': 'Storage & Cache',
      'version_info': 'Version Info',
      'clear_search_history': 'Clear Search History',
      'legal_support': 'Legal & Support',
      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'licenses': 'Licenses',
      'log_out': 'Log Out',
      'select_language': 'Select Language',
      'appearance_theme': 'Appearance & Theme',
      'connected_accounts': 'Connected Accounts',
      'manage_social': 'Manage linked social logins and third-party services',
      'order_prep_alerts': 'Order status, preparation & alerts',
      'order_receipts': 'Order receipts & chef highlights',
      'urgent_sms': 'Urgent delivery updates to your phone',
      'home': 'Home',
      'promo': 'Promo',
      'orders': 'Orders',
      'favorites': 'Favorites',
      'profile': 'Profile',
    },
    'Bahasa Indonesia': {
      'settings': 'Pengaturan',
      'account_settings': 'Pengaturan Akun',
      'personal_information': 'Informasi Pribadi',
      'password_security': 'Keamanan & Kata Sandi',
      'social_accounts': 'Akun Media Sosial',
      'delete_account': 'Hapus Akun',
      'preferences': 'Preferensi',
      'notification_settings': 'Pengaturan Notifikasi',
      'push_notifications': 'Notifikasi Push',
      'email_notifications': 'Notifikasi Email',
      'sms_alerts': 'Peringatan SMS',
      'privacy_data': 'Privasi & Data Pengguna',
      'language': 'Bahasa',
      'appearance': 'Tampilan Tema',
      'app_settings': 'Pengaturan Aplikasi',
      'storage_cache': 'Penyimpanan & Cache',
      'version_info': 'Informasi Versi',
      'clear_search_history': 'Hapus Riwayat Pencarian',
      'legal_support': 'Hukum & Bantuan',
      'terms_of_service': 'Ketentuan Layanan',
      'privacy_policy': 'Kebijakan Privasi',
      'licenses': 'Lisensi Perangkat Lunak',
      'log_out': 'Keluar Akun',
      'select_language': 'Pilih Bahasa',
      'appearance_theme': 'Tampilan & Tema',
      'connected_accounts': 'Akun Terhubung',
      'manage_social': 'Kelola login sosial dan layanan pihak ketiga',
      'order_prep_alerts': 'Status pesanan, persiapan makanan & update',
      'order_receipts': 'Bukti pembayaran pesanan & info chef',
      'urgent_sms': 'Pemberitahuan darurat pengantaran ke nomor HP',
      'home': 'Beranda',
      'promo': 'Promo',
      'orders': 'Pesanan',
      'favorites': 'Favorit',
      'profile': 'Profil',
    },
    'Español': {
      'settings': 'Ajustes',
      'account_settings': 'Ajustes de la Cuenta',
      'personal_information': 'Información Personal',
      'password_security': 'Contraseña y Seguridad',
      'social_accounts': 'Cuentas Vinculadas',
      'delete_account': 'Eliminar Cuenta',
      'preferences': 'Preferencias',
      'notification_settings': 'Ajustes de Notificación',
      'push_notifications': 'Notificaciones Push',
      'email_notifications': 'Notificaciones por Correo',
      'sms_alerts': 'Alertas por SMS',
      'privacy_data': 'Privacidad y Datos',
      'language': 'Idioma',
      'appearance': 'Apariencia',
      'app_settings': 'Ajustes de la Aplicación',
      'storage_cache': 'Almacenamiento y Caché',
      'version_info': 'Información de Versión',
      'clear_search_history': 'Borrar Historial de Búsqueda',
      'legal_support': 'Legal y Soporte',
      'terms_of_service': 'Términos de Servicio',
      'privacy_policy': 'Política de Privacidad',
      'licenses': 'Licencias',
      'log_out': 'Cerrar Sesión',
      'select_language': 'Seleccionar Idioma',
      'appearance_theme': 'Apariencia y Tema',
      'connected_accounts': 'Cuentas Conectadas',
      'manage_social': 'Gestionar cuentas sociales vinculadas',
      'order_prep_alerts': 'Estado del pedido, preparación y alertas',
      'order_receipts': 'Recibos de pedidos y novedades de chefs',
      'urgent_sms': 'Actualizaciones urgentes de entrega a tu teléfono',
      'home': 'Inicio',
      'promo': 'Promos',
      'orders': 'Pedidos',
      'favorites': 'Favoritos',
      'profile': 'Perfil',
    },
    'Français': {
      'settings': 'Paramètres',
      'account_settings': 'Paramètres du Compte',
      'personal_information': 'Informations Personnelles',
      'password_security': 'Mot de Passe & Sécurité',
      'social_accounts': 'Comptes Associés',
      'delete_account': 'Supprimer le Compte',
      'preferences': 'Préférences',
      'notification_settings': 'Paramètres de Notification',
      'push_notifications': 'Notifications Push',
      'email_notifications': 'Notifications par E-mail',
      'sms_alerts': 'Alertes SMS',
      'privacy_data': 'Confidentialité & Données',
      'language': 'Langue',
      'appearance': 'Apparence',
      'app_settings': 'Paramètres de l\'App',
      'storage_cache': 'Stockage & Cache',
      'version_info': 'Infos sur la Version',
      'clear_search_history': 'Effacer l\'Historique',
      'legal_support': 'Légal & Support',
      'terms_of_service': 'Conditions d\'Utilisation',
      'privacy_policy': 'Politique de Confidentialité',
      'licenses': 'Licences',
      'log_out': 'Déconnexion',
      'select_language': 'Choisir la Langue',
      'appearance_theme': 'Apparence & Thème',
      'connected_accounts': 'Comptes Connectés',
      'manage_social': 'Gérer les connexions sociales et services tiers',
      'order_prep_alerts': 'Statut des commandes et préparation',
      'order_receipts': 'Reçus de commande et actualités chef',
      'urgent_sms': 'Mises à jour urgentes par SMS',
      'home': 'Accueil',
      'promo': 'Promos',
      'orders': 'Commandes',
      'favorites': 'Favoris',
      'profile': 'Profil',
    },
    'Deutsch': {
      'settings': 'Einstellungen',
      'account_settings': 'Kontoeinstellungen',
      'personal_information': 'Persönliche Angaben',
      'password_security': 'Passwort & Sicherheit',
      'social_accounts': 'Verknüpfte Konten',
      'delete_account': 'Konto Löschen',
      'preferences': 'Präferenzen',
      'notification_settings': 'Benachrichtigungen',
      'push_notifications': 'Push-Benachrichtigungen',
      'email_notifications': 'E-Mail-Benachrichtigungen',
      'sms_alerts': 'SMS-Benachrichtigungen',
      'privacy_data': 'Datenschutz & Daten',
      'language': 'Sprache',
      'appearance': 'Erscheinungsbild',
      'app_settings': 'App-Einstellungen',
      'storage_cache': 'Speicher & Cache',
      'version_info': 'Versionsinformationen',
      'clear_search_history': 'Suchverlauf Löschen',
      'legal_support': 'Rechtliches & Support',
      'terms_of_service': 'Nutzungsbedingungen',
      'privacy_policy': 'Datenschutzrichtlinie',
      'licenses': 'Lizenzen',
      'log_out': 'Abmelden',
      'select_language': 'Sprache Wählen',
      'appearance_theme': 'Erscheinungsbild & Design',
      'connected_accounts': 'Verknüpfte Konten',
      'manage_social': 'Verknüpfte Konten und Drittanbieter verwalten',
      'order_prep_alerts': 'Bestellstatus und Vorbereitungsinfos',
      'order_receipts': 'Bestellbelege und Highlights',
      'urgent_sms': 'Dringende Lieferaktualisierungen per SMS',
      'home': 'Start',
      'promo': 'Angebote',
      'orders': 'Bestellungen',
      'favorites': 'Favoriten',
      'profile': 'Profil',
    },
  };
}
