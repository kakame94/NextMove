# App Store — Privacy Nutrition Labels

Filed under "App Privacy" in App Store Connect for `ai.klarisapp.klaris_ios`.

## Data Used to Track You

**None.** Klaris does not track users across other companies' apps or websites.

## Data Linked to You

| Category | Item | Purpose | Note |
|----------|------|---------|------|
| Contact Info | Email | App Functionality | Auth (Supabase) |
| Contact Info | Phone | App Functionality | Broker phone for Twilio routing |
| Identifiers | User ID | App Functionality | Supabase `auth.users.id` (UUID) |
| Identifiers | Device ID | App Functionality | FCM token (push notif routing only) |
| Usage Data | Product Interaction | Analytics | Audit log (OACIQ traceability) |
| Diagnostics | Crash Data | App Functionality | Sentry (planned, not yet wired) |
| User Content | Other User Content | App Functionality | Prospect SMS transcripts |
| Location | Coarse Location | App Functionality | Prospect address geocoding (broker-entered) |

## Data Not Linked to You

None — every data point is associated with the broker user account by design (RLS).

## Privacy Practices

- All personal data hosted in **Canada** (Supabase `ca-central-1`).
- Conforms to **Quebec Law 25** (consent, opt-out, access, deletion).
- Conforms to **CASL** (anti-spam, business-hour SMS only, STOP recognition).
- Conforms to **OACIQ** broker oversight (every action traced + signed by broker).
- Audit log retained 7 years (OACIQ requirement).
- No third-party advertising.
- No data resale.

## Required Info.plist Strings

```xml
<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string>Klaris ajoute tes rendez-vous prospects à ton agenda iOS.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Klaris transcrit tes notes vocales en texte automatiquement.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Klaris affiche tes prospects sur la carte autour de ta position.</string>

<key>NSContactsUsageDescription</key>
<string>Optionnel — pour préremplir les fiches prospects depuis tes contacts.</string>
```

## URLs (App Store Connect)

- Privacy policy: `https://klarisapp.ai/privacy`
- Marketing URL: `https://klarisapp.ai`
- Support URL: `https://klarisapp.ai/support`
