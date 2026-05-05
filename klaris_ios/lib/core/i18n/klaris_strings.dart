import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FR/EN strings — meme convention que web (key-value flat map).
/// User-toggleable via [langProvider].
enum KlarisLang { fr, en }

final langProvider = StateProvider<KlarisLang>((ref) => KlarisLang.fr);

abstract class KlarisStrings {
  KlarisStrings._();

  static const Map<String, Map<KlarisLang, String>> _t = {
    // Auth
    'auth.title':           {KlarisLang.fr: 'Bienvenue sur Klaris',   KlarisLang.en: 'Welcome to Klaris'},
    'auth.subtitle':        {KlarisLang.fr: 'Ton adjointe IA est prete a travailler.', KlarisLang.en: 'Your AI assistant is ready to work.'},
    'auth.email':           {KlarisLang.fr: 'Courriel',                KlarisLang.en: 'Email'},
    'auth.password':        {KlarisLang.fr: 'Mot de passe',            KlarisLang.en: 'Password'},
    'auth.signin':          {KlarisLang.fr: 'Se connecter',            KlarisLang.en: 'Sign in'},
    'auth.signup':          {KlarisLang.fr: 'Creer un compte',         KlarisLang.en: 'Create account'},
    'auth.forgot':          {KlarisLang.fr: 'Mot de passe oublie?',    KlarisLang.en: 'Forgot password?'},
    'auth.error.invalid':   {KlarisLang.fr: 'Identifiants invalides.', KlarisLang.en: 'Invalid credentials.'},
    'auth.compliance':      {KlarisLang.fr: 'Conforme OACIQ - Loi 25 - CASL', KlarisLang.en: 'OACIQ - Law 25 - CASL compliant'},

    // Tabs
    'tab.prospects':        {KlarisLang.fr: 'Prospects',  KlarisLang.en: 'Prospects'},
    'tab.conversations':    {KlarisLang.fr: 'Echanges',   KlarisLang.en: 'Threads'},
    'tab.relances':         {KlarisLang.fr: 'Relances',   KlarisLang.en: 'Follow-ups'},
    'tab.settings':         {KlarisLang.fr: 'Reglages',   KlarisLang.en: 'Settings'},

    // Prospects
    'prospects.title':      {KlarisLang.fr: 'Prospects', KlarisLang.en: 'Prospects'},
    'prospects.empty':      {KlarisLang.fr: 'Aucun prospect pour l\'instant.', KlarisLang.en: 'No prospects yet.'},
    'prospects.refresh':    {KlarisLang.fr: 'Tirer pour rafraichir', KlarisLang.en: 'Pull to refresh'},
    'prospects.filter.all': {KlarisLang.fr: 'Tous',      KlarisLang.en: 'All'},
    'prospects.filter.hot': {KlarisLang.fr: 'Chauds',    KlarisLang.en: 'Hot'},
    'prospects.filter.warm':{KlarisLang.fr: 'Tiedes',    KlarisLang.en: 'Warm'},
    'prospects.filter.cold':{KlarisLang.fr: 'Froids',    KlarisLang.en: 'Cold'},
    'prospects.score':      {KlarisLang.fr: 'Score',     KlarisLang.en: 'Score'},
    'prospects.budget':     {KlarisLang.fr: 'Budget',    KlarisLang.en: 'Budget'},
    'prospects.area':       {KlarisLang.fr: 'Secteur',   KlarisLang.en: 'Area'},
    'prospects.delay':      {KlarisLang.fr: 'Delai',     KlarisLang.en: 'Timeline'},
    'prospects.preapproved':{KlarisLang.fr: 'Pre-approuve', KlarisLang.en: 'Pre-approved'},
    'prospects.callback':   {KlarisLang.fr: 'Rappeler',  KlarisLang.en: 'Call back'},
    'prospects.transcript': {KlarisLang.fr: 'Voir le transcript', KlarisLang.en: 'View transcript'},

    // Common
    'common.cancel':        {KlarisLang.fr: 'Annuler', KlarisLang.en: 'Cancel'},
    'common.confirm':       {KlarisLang.fr: 'Confirmer', KlarisLang.en: 'Confirm'},
    'common.error':         {KlarisLang.fr: 'Erreur', KlarisLang.en: 'Error'},
    'common.retry':         {KlarisLang.fr: 'Reessayer', KlarisLang.en: 'Retry'},
  };

  /// Lookup. Returns the key itself in dev if missing — easy to spot.
  static String t(String key, KlarisLang lang) => _t[key]?[lang] ?? key;
}

extension KlarisStringsX on WidgetRef {
  String s(String key) => KlarisStrings.t(key, watch(langProvider));
}
