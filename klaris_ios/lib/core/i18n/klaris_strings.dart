import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FR/EN/ES strings — meme convention que web (key-value flat map).
/// User-toggleable via [langProvider].
enum KlarisLang { fr, en, es }

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
    'auth.or':              {KlarisLang.fr: 'ou',                       KlarisLang.en: 'or'},
    'auth.apple':           {KlarisLang.fr: 'Continuer avec Apple',     KlarisLang.en: 'Continue with Apple'},

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

    // Recommendations (Sprint 7 — AI listing matches)
    'reco.title':           {KlarisLang.fr: 'Recommandations IA',    KlarisLang.en: 'AI recommendations'},
    'reco.empty':           {KlarisLang.fr: 'Aucune correspondance pour ce profil.',
                             KlarisLang.en: 'No matches for this profile.'},
    'reco.error':           {KlarisLang.fr: 'Impossible de charger les recommandations.',
                             KlarisLang.en: 'Could not load recommendations.'},

    // Conversations
    'conv.empty':           {KlarisLang.fr: 'Aucun echange.',           KlarisLang.en: 'No threads yet.'},
    'conv.thread.title':    {KlarisLang.fr: 'Conversation',             KlarisLang.en: 'Thread'},
    'conv.composer.hint':   {KlarisLang.fr: 'Ecris ton message...',     KlarisLang.en: 'Type your message...'},
    'conv.composer.handover':{KlarisLang.fr: 'En envoyant, Klaris se met en retrait pour cette conversation.',
                              KlarisLang.en: 'When you send, Klaris steps aside for this thread.'},

    // Relances
    'relance.banner':       {KlarisLang.fr: 'Klaris prepare chaque relance. Tu valides avant envoi.',
                             KlarisLang.en: 'Klaris drafts every follow-up. You approve before sending.'},
    'relance.empty':        {KlarisLang.fr: 'Aucune relance en attente.', KlarisLang.en: 'No pending follow-ups.'},
    'relance.overdue':      {KlarisLang.fr: 'En retard',                KlarisLang.en: 'Overdue'},
    'relance.approve':      {KlarisLang.fr: 'Envoyer',                  KlarisLang.en: 'Send'},
    'relance.skip':         {KlarisLang.fr: 'Passer',                   KlarisLang.en: 'Skip'},

    // Settings
    'settings.broker':              {KlarisLang.fr: 'Courtier · Compte actif',     KlarisLang.en: 'Broker · Active account'},
    'settings.appearance':          {KlarisLang.fr: 'Apparence',                   KlarisLang.en: 'Appearance'},
    'settings.theme':               {KlarisLang.fr: 'Theme',                       KlarisLang.en: 'Theme'},
    'settings.theme.system':        {KlarisLang.fr: 'Systeme',                     KlarisLang.en: 'System'},
    'settings.theme.light':         {KlarisLang.fr: 'Clair',                       KlarisLang.en: 'Light'},
    'settings.theme.dark':          {KlarisLang.fr: 'Sombre',                      KlarisLang.en: 'Dark'},
    'settings.language':            {KlarisLang.fr: 'Langue',                      KlarisLang.en: 'Language'},
    'settings.privacy':             {KlarisLang.fr: 'Confidentialite',             KlarisLang.en: 'Privacy'},
    'settings.optout':              {KlarisLang.fr: 'Retrait du programme (Loi 25)', KlarisLang.en: 'Opt out (Law 25)'},
    'settings.optout.hint':         {KlarisLang.fr: 'Suspendre tout traitement IA, conserver acces lecture seule.',
                                     KlarisLang.en: 'Suspend AI processing, keep read-only access.'},
    'settings.optout.title':        {KlarisLang.fr: 'Retrait du programme', KlarisLang.en: 'Opt out'},
    'settings.optout.body':         {KlarisLang.fr: 'Klaris arretera de qualifier et relancer tes prospects. Action reversible. Conforme Loi 25.',
                                     KlarisLang.en: 'Klaris will stop qualifying and following up with your prospects. Reversible. Law 25 compliant.'},
    'settings.optout.confirm':      {KlarisLang.fr: 'Confirmer le retrait', KlarisLang.en: 'Confirm opt-out'},
    'settings.dataExport':          {KlarisLang.fr: 'Exporter mes donnees',  KlarisLang.en: 'Export my data'},
    'settings.dataExport.hint':     {KlarisLang.fr: 'CSV + transcript SMS, livre par courriel.', KlarisLang.en: 'CSV + SMS transcript, delivered by email.'},
    'settings.dnd':                 {KlarisLang.fr: 'Ne pas deranger', KlarisLang.en: 'Do not disturb'},
    'settings.dnd.hint':            {KlarisLang.fr: 'Couper les notifs hors heures ouvrables QC.', KlarisLang.en: 'Mute notifs outside QC business hours.'},
    'settings.about':               {KlarisLang.fr: 'A propos',  KlarisLang.en: 'About'},
    'settings.version':             {KlarisLang.fr: 'Version',   KlarisLang.en: 'Version'},
    'settings.region':              {KlarisLang.fr: 'Region',    KlarisLang.en: 'Region'},
    'settings.compliance':          {KlarisLang.fr: 'Conformite',KlarisLang.en: 'Compliance'},
    'settings.signout':             {KlarisLang.fr: 'Se deconnecter', KlarisLang.en: 'Sign out'},

    // Briefing
    'briefing.title':       {KlarisLang.fr: 'Briefing du jour',           KlarisLang.en: 'Daily briefing'},
    'briefing.greeting':    {KlarisLang.fr: 'Bonjour 👋',                  KlarisLang.en: 'Good morning 👋'},
    'briefing.empty':       {KlarisLang.fr: 'Aucun briefing pour aujourd\'hui. Tire vers le bas pour rafraichir.', KlarisLang.en: 'No briefing yet today. Pull down to refresh.'},
    'briefing.kpi.hot':     {KlarisLang.fr: 'Chauds',     KlarisLang.en: 'Hot'},
    'briefing.kpi.new':     {KlarisLang.fr: 'Nouveaux',   KlarisLang.en: 'New'},
    'briefing.kpi.relances':{KlarisLang.fr: 'Relances',   KlarisLang.en: 'Follow-ups'},
    'briefing.kpi.unread':  {KlarisLang.fr: 'Non lus',    KlarisLang.en: 'Unread'},
    'briefing.section.hot':     {KlarisLang.fr: 'Top prospects chauds',   KlarisLang.en: 'Top hot prospects'},
    'briefing.section.new':     {KlarisLang.fr: 'Nouveaux dernieres 24h', KlarisLang.en: 'New in last 24h'},
    'briefing.section.relances':{KlarisLang.fr: 'Relances aujourd\'hui',  KlarisLang.en: 'Today\'s follow-ups'},
    'briefing.footer':      {KlarisLang.fr: 'Klaris regenere ce briefing chaque matin a 7h30.', KlarisLang.en: 'Klaris regenerates this briefing every morning at 7:30am.'},

    // Create
    'create.title':         {KlarisLang.fr: 'Nouveau prospect',  KlarisLang.en: 'New prospect'},
    'create.next':          {KlarisLang.fr: 'Suivant',           KlarisLang.en: 'Next'},
    'create.back':          {KlarisLang.fr: 'Retour',            KlarisLang.en: 'Back'},
    'create.save':          {KlarisLang.fr: 'Enregistrer',       KlarisLang.en: 'Save'},
    'create.q1':            {KlarisLang.fr: 'Comment s\'appelle ton prospect?', KlarisLang.en: 'What\'s their name?'},
    'create.q2':            {KlarisLang.fr: 'Numero de telephone?',             KlarisLang.en: 'Phone number?'},
    'create.q3':            {KlarisLang.fr: 'Acheteur ou vendeur?',             KlarisLang.en: 'Buyer or seller?'},
    'create.q4':            {KlarisLang.fr: 'Quel secteur t\'interesse?',       KlarisLang.en: 'Which area?'},
    'create.q5':            {KlarisLang.fr: 'Quel budget?',                     KlarisLang.en: 'What budget?'},
    'create.buyer':         {KlarisLang.fr: 'Acheteur',          KlarisLang.en: 'Buyer'},
    'create.seller':        {KlarisLang.fr: 'Vendeur',           KlarisLang.en: 'Seller'},
    'create.delai':         {KlarisLang.fr: 'Delai d\'action',   KlarisLang.en: 'Timeline'},
    'create.preapproved':   {KlarisLang.fr: 'Pre-approuve hypotheque', KlarisLang.en: 'Pre-approved mortgage'},
    'create.preapproved.hint': {KlarisLang.fr: 'Bonus de +3 au scoring si oui.', KlarisLang.en: 'Adds +3 to scoring.'},

    // Filters
    'filters.title':        {KlarisLang.fr: 'Filtres avances',   KlarisLang.en: 'Advanced filters'},
    'filters.reset':        {KlarisLang.fr: 'Reinitialiser',     KlarisLang.en: 'Reset'},
    'filters.apply':        {KlarisLang.fr: 'Appliquer',         KlarisLang.en: 'Apply'},
    'filters.all':          {KlarisLang.fr: 'Tous',              KlarisLang.en: 'All'},
    'filters.type':         {KlarisLang.fr: 'Type',              KlarisLang.en: 'Type'},
    'filters.area':         {KlarisLang.fr: 'Secteur',           KlarisLang.en: 'Area'},
    'filters.budget':       {KlarisLang.fr: 'Budget',            KlarisLang.en: 'Budget'},
    'filters.delay':        {KlarisLang.fr: 'Delai',             KlarisLang.en: 'Timeline'},

    // Stats
    'stats.title':          {KlarisLang.fr: 'Statistiques',      KlarisLang.en: 'Stats'},
    'stats.total':          {KlarisLang.fr: 'Total prospects',   KlarisLang.en: 'Total prospects'},
    'stats.hot':            {KlarisLang.fr: 'Chauds actifs',     KlarisLang.en: 'Active hot'},
    'stats.avgscore':       {KlarisLang.fr: 'Score moyen',       KlarisLang.en: 'Avg score'},
    'stats.conv':           {KlarisLang.fr: 'Conversion',        KlarisLang.en: 'Conversion'},
    'stats.activity':       {KlarisLang.fr: 'Activite 6 mois',   KlarisLang.en: '6-month activity'},
    'stats.activity.sub':   {KlarisLang.fr: 'Nouveaux, qualifies, conclus par mois.', KlarisLang.en: 'New, qualified, closed per month.'},
    'stats.legend.new':       {KlarisLang.fr: 'Nouveaux',   KlarisLang.en: 'New'},
    'stats.legend.qualified': {KlarisLang.fr: 'Qualifies',  KlarisLang.en: 'Qualified'},
    'stats.legend.closed':    {KlarisLang.fr: 'Conclus',    KlarisLang.en: 'Closed'},

    // Search
    'search.title':         {KlarisLang.fr: 'Recherche',                    KlarisLang.en: 'Search'},
    'search.placeholder':   {KlarisLang.fr: 'Nom, telephone, secteur...',   KlarisLang.en: 'Name, phone, area...'},
    'search.hint':          {KlarisLang.fr: 'Tape au moins 2 caracteres pour chercher.', KlarisLang.en: 'Type at least 2 characters to search.'},
    'search.searching':     {KlarisLang.fr: 'Recherche en cours...',        KlarisLang.en: 'Searching...'},
    'search.empty':         {KlarisLang.fr: 'Aucun prospect trouve.',       KlarisLang.en: 'No prospect found.'},

    // Calendar
    'calendar.title':           {KlarisLang.fr: 'Agenda',                       KlarisLang.en: 'Calendar'},
    'calendar.empty':           {KlarisLang.fr: 'Aucun rendez-vous ce jour-la.',KlarisLang.en: 'No appointments this day.'},
    'calendar.create.title':    {KlarisLang.fr: 'Nouveau rendez-vous',          KlarisLang.en: 'New appointment'},
    'calendar.create.label':    {KlarisLang.fr: 'Titre',                        KlarisLang.en: 'Title'},
    'calendar.create.prospect': {KlarisLang.fr: 'Prospect',                     KlarisLang.en: 'Prospect'},
    'calendar.create.pick':     {KlarisLang.fr: 'Choisir un prospect',          KlarisLang.en: 'Pick a prospect'},
    'calendar.create.when':     {KlarisLang.fr: 'Quand',                        KlarisLang.en: 'When'},
    'calendar.create.location': {KlarisLang.fr: 'Lieu',                         KlarisLang.en: 'Location'},
    'calendar.create.notes':    {KlarisLang.fr: 'Notes',                        KlarisLang.en: 'Notes'},
    'calendar.create.notes.hint': {KlarisLang.fr: 'Documents a apporter, points a couvrir...', KlarisLang.en: 'Docs to bring, points to cover...'},
    'calendar.create.addToCal': {KlarisLang.fr: 'Ajouter a l\'agenda iOS',      KlarisLang.en: 'Add to iOS Calendar'},
    'calendar.create.addToCal.hint': {KlarisLang.fr: 'Synchronise via EventKit. Demande la permission au premier ajout.', KlarisLang.en: 'Synced via EventKit. Permission requested on first add.'},

    // Templates
    'templates.title':      {KlarisLang.fr: 'Templates SMS',         KlarisLang.en: 'SMS templates'},
    'templates.hint':       {KlarisLang.fr: 'Snippets reutilisables pour le composer.', KlarisLang.en: 'Reusable snippets for the composer.'},
    'templates.empty':      {KlarisLang.fr: 'Aucun template. Cree-en un pour gagner du temps.', KlarisLang.en: 'No template. Create one to save time.'},
    'templates.create':     {KlarisLang.fr: 'Nouveau template',     KlarisLang.en: 'New template'},
    'templates.edit':       {KlarisLang.fr: 'Modifier',             KlarisLang.en: 'Edit'},
    'templates.delete':     {KlarisLang.fr: 'Supprimer',            KlarisLang.en: 'Delete'},
    'templates.shortcode':  {KlarisLang.fr: 'Code court',           KlarisLang.en: 'Short code'},
    'templates.shortcode.hint': {KlarisLang.fr: 'Tape /code dans le composer pour l\'inserer.', KlarisLang.en: 'Type /code in composer to insert.'},
    'templates.label':      {KlarisLang.fr: 'Etiquette',            KlarisLang.en: 'Label'},
    'templates.body':       {KlarisLang.fr: 'Message',              KlarisLang.en: 'Message'},
    'templates.placeholders': {KlarisLang.fr: 'Variables disponibles', KlarisLang.en: 'Available variables'},
    'templates.uses':       {KlarisLang.fr: 'Utilise {n} fois',     KlarisLang.en: 'Used {n} times'},

    // Agency
    'agency.title':         {KlarisLang.fr: 'Agence',               KlarisLang.en: 'Agency'},
    'agency.hint':          {KlarisLang.fr: 'Tableau equipe, attribution leads.', KlarisLang.en: 'Team dashboard, lead attribution.'},
    'agency.solo':          {KlarisLang.fr: 'Tu es en mode solo. Aucune agence rattachee.', KlarisLang.en: 'You\'re in solo mode. No agency linked.'},
    'agency.broker.locked.title': {KlarisLang.fr: 'Reserve aux admins', KlarisLang.en: 'Admin only'},
    'agency.broker.locked.body':  {KlarisLang.fr: 'Le tableau equipe est visible aux roles admin et manager seulement.', KlarisLang.en: 'Team dashboard is visible to admin and manager roles only.'},
    'agency.team':          {KlarisLang.fr: '{n} courtiers',         KlarisLang.en: '{n} brokers'},
    'agency.team.title':    {KlarisLang.fr: 'Performance equipe',    KlarisLang.en: 'Team performance'},
    'agency.stat.prospects':{KlarisLang.fr: 'Prospects',             KlarisLang.en: 'Prospects'},
    'agency.stat.hot':      {KlarisLang.fr: 'Chauds',                KlarisLang.en: 'Hot'},
    'agency.stat.score':    {KlarisLang.fr: 'Score',                 KlarisLang.en: 'Score'},
    'agency.stat.closed30d':{KlarisLang.fr: 'Conclus 30j',           KlarisLang.en: 'Closed 30d'},
    'agency.assign.title':  {KlarisLang.fr: 'Reassigner a',          KlarisLang.en: 'Reassign to'},

    // Feedback
    'feedback.title':       {KlarisLang.fr: 'Donner du feedback',                   KlarisLang.en: 'Send feedback'},
    'feedback.subtitle':    {KlarisLang.fr: 'Cree un ticket Linear directement.',   KlarisLang.en: 'Creates a Linear ticket directly.'},
    'feedback.hint':        {KlarisLang.fr: 'Bug, idee, ou eloge — on lit tout.',   KlarisLang.en: 'Bug, idea, or praise — we read everything.'},
    'feedback.bug':         {KlarisLang.fr: 'Bug',     KlarisLang.en: 'Bug'},
    'feedback.feature':     {KlarisLang.fr: 'Idee',    KlarisLang.en: 'Idea'},
    'feedback.praise':      {KlarisLang.fr: 'Eloge',   KlarisLang.en: 'Praise'},
    'feedback.title.hint':  {KlarisLang.fr: 'Sujet en quelques mots',               KlarisLang.en: 'Subject in a few words'},
    'feedback.body.hint':   {KlarisLang.fr: 'Decris ce que tu vois ou ce que tu veux...', KlarisLang.en: 'Describe what you see or what you want...'},
    'feedback.send':        {KlarisLang.fr: 'Envoyer',                              KlarisLang.en: 'Send'},
    'feedback.thanks':      {KlarisLang.fr: 'Merci! Le ticket est cree.',           KlarisLang.en: 'Thanks! Ticket created.'},

    // Detail actions
    'detail.action.appointment': {KlarisLang.fr: 'Planifier un rendez-vous', KlarisLang.en: 'Schedule appointment'},
    'detail.action.memo':        {KlarisLang.fr: 'Note vocale',              KlarisLang.en: 'Voice memo'},
    'detail.action.assign':      {KlarisLang.fr: 'Reassigner ce lead',       KlarisLang.en: 'Reassign this lead'},

    // Map
    'map.title':            {KlarisLang.fr: 'Carte',                              KlarisLang.en: 'Map'},
    'map.empty':            {KlarisLang.fr: 'Aucun prospect avec adresse geolocalisable.', KlarisLang.en: 'No prospect with geocoded address.'},
    'map.count':            {KlarisLang.fr: '{n} prospects',                      KlarisLang.en: '{n} prospects'},

    // Voice memo
    'memo.title':           {KlarisLang.fr: 'Note vocale',                        KlarisLang.en: 'Voice memo'},
    'memo.hint':            {KlarisLang.fr: 'Enregistre une note. Klaris transcrit + resume automatiquement.', KlarisLang.en: 'Record a note. Klaris transcribes + summarizes automatically.'},
    'memo.send':            {KlarisLang.fr: 'Envoyer pour transcription',         KlarisLang.en: 'Send for transcription'},
    'memo.error.permission':{KlarisLang.fr: 'Permission micro refusee. Active dans Reglages > Klaris.', KlarisLang.en: 'Microphone permission denied. Enable in Settings > Klaris.'},

    // Onboarding
    'onboarding.skip':      {KlarisLang.fr: 'Passer',                              KlarisLang.en: 'Skip'},
    'onboarding.next':      {KlarisLang.fr: 'Suivant',                             KlarisLang.en: 'Next'},
    'onboarding.start':     {KlarisLang.fr: 'C\'est parti',                        KlarisLang.en: 'Get started'},
    'ob.1.eyebrow':         {KlarisLang.fr: 'BIENVENUE',                           KlarisLang.en: 'WELCOME'},
    'ob.1.title':           {KlarisLang.fr: 'Klaris, ton adjointe IA.',            KlarisLang.en: 'Klaris, your AI assistant.'},
    'ob.1.body':            {KlarisLang.fr: 'Elle qualifie tes prospects pendant que tu vends.', KlarisLang.en: 'She qualifies your prospects while you sell.'},
    'ob.2.eyebrow':         {KlarisLang.fr: 'CONVERSATION',                        KlarisLang.en: 'CONVERSATION'},
    'ob.2.title':           {KlarisLang.fr: 'Reponse en 60 secondes.',             KlarisLang.en: 'Reply in 60 seconds.'},
    'ob.2.body':            {KlarisLang.fr: 'SMS bilingue, ton naturel quebecois, jamais d\'IA deguisee.', KlarisLang.en: 'Bilingual SMS, Quebec-natural tone, never disguised as AI.'},
    'ob.3.eyebrow':         {KlarisLang.fr: 'SCORING',                             KlarisLang.en: 'SCORING'},
    'ob.3.title':           {KlarisLang.fr: 'Lead chaud = action immediate.',      KlarisLang.en: 'Hot lead = immediate action.'},
    'ob.3.body':            {KlarisLang.fr: 'Score 0 a 10 calcule automatiquement, explique en clair.', KlarisLang.en: 'Score 0 to 10 computed automatically, explained in plain words.'},
    'ob.4.eyebrow':         {KlarisLang.fr: 'AGENDA + RELANCES',                   KlarisLang.en: 'CALENDAR + FOLLOW-UPS'},
    'ob.4.title':           {KlarisLang.fr: 'Tout au meme endroit.',               KlarisLang.en: 'All in one place.'},
    'ob.4.body':            {KlarisLang.fr: 'Rendez-vous dans iOS Calendar, relances J+2/5/10 que tu valides.', KlarisLang.en: 'Appointments in iOS Calendar, follow-ups D+2/5/10 you approve.'},
    'ob.5.eyebrow':         {KlarisLang.fr: 'CONFORMITE',                          KlarisLang.en: 'COMPLIANCE'},
    'ob.5.title':           {KlarisLang.fr: 'OACIQ. Loi 25. CASL.',                KlarisLang.en: 'OACIQ. Law 25. CASL.'},
    'ob.5.body':            {KlarisLang.fr: 'Hebergement Canada. Tout est trace, signe par toi.', KlarisLang.en: 'Canadian hosting. Everything traced, signed by you.'},

    // Common
    'common.cancel':        {KlarisLang.fr: 'Annuler', KlarisLang.en: 'Cancel'},
    'common.confirm':       {KlarisLang.fr: 'Confirmer', KlarisLang.en: 'Confirm'},
    'common.error':         {KlarisLang.fr: 'Erreur', KlarisLang.en: 'Error'},
    'common.retry':         {KlarisLang.fr: 'Reessayer', KlarisLang.en: 'Retry'},
  };

  /// Lookup. ES falls back to EN when not yet translated, then to the key.
  static String t(String key, KlarisLang lang) {
    final entry = _t[key];
    if (entry == null) return _es[key] ?? key;
    final direct = entry[lang];
    if (direct != null) return direct;
    if (lang == KlarisLang.es) {
      // ES fallback chain: ES override map → EN
      return _es[key] ?? entry[KlarisLang.en] ?? key;
    }
    return key;
  }

  /// Spanish-only override map (subset). Anything missing falls back to EN.
  static const Map<String, String> _es = {
    'auth.title':         'Bienvenido a Klaris',
    'auth.subtitle':      'Tu asistente IA esta lista para trabajar.',
    'auth.email':         'Correo',
    'auth.password':      'Contrasena',
    'auth.signin':        'Iniciar sesion',
    'auth.signup':        'Crear cuenta',
    'auth.forgot':        'Contrasena olvidada?',
    'auth.error.invalid':'Credenciales invalidas.',
    'auth.compliance':    'Cumplimiento OACIQ - Ley 25 - CASL',
    'auth.or':            'o',
    'auth.apple':         'Continuar con Apple',

    'tab.prospects':      'Prospectos',
    'tab.conversations':  'Mensajes',
    'tab.relances':       'Seguimientos',
    'tab.settings':       'Ajustes',

    'prospects.title':    'Prospectos',
    'prospects.empty':    'Sin prospectos por ahora.',
    'prospects.filter.all':  'Todos',
    'prospects.filter.hot':  'Calientes',
    'prospects.filter.warm': 'Tibios',
    'prospects.filter.cold': 'Frios',
    'prospects.score':    'Puntuacion',
    'prospects.budget':   'Presupuesto',
    'prospects.area':     'Zona',
    'prospects.delay':    'Plazo',
    'prospects.preapproved': 'Preaprobado',
    'prospects.callback': 'Llamar',
    'prospects.transcript': 'Ver transcripcion',

    'reco.title':         'Recomendaciones IA',
    'reco.empty':         'Sin coincidencias para este perfil.',
    'reco.error':         'No se pudieron cargar las recomendaciones.',

    'common.cancel':      'Cancelar',
    'common.confirm':     'Confirmar',
    'common.error':       'Error',
    'common.retry':       'Reintentar',

    'briefing.title':     'Resumen del dia',
    'briefing.greeting':  'Buenos dias',

    'search.title':       'Busqueda',
    'search.placeholder': 'Nombre, telefono, zona...',
    'search.empty':       'Sin resultados.',

    'calendar.title':     'Agenda',
    'map.title':          'Mapa',
    'memo.title':         'Nota de voz',

    'settings.theme':     'Tema',
    'settings.language':  'Idioma',
    'settings.signout':   'Cerrar sesion',

    'onboarding.skip':    'Saltar',
    'onboarding.next':    'Siguiente',
    'onboarding.start':   'Empezar',
  };
}

extension KlarisStringsX on WidgetRef {
  String s(String key) => KlarisStrings.t(key, watch(langProvider));
}
