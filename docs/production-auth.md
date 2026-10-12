# Production authentication
Debug builds open the UI locally. Release and profile builds always use the Firebase gate; debug can exercise it with PyinccApp(requireAuthentication: true).

Configure the actual Firebase Android application com.pyincc.fashionai and enable Email/Password in Authentication. Supply FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID through --dart-define-from-file with your project's Firebase client configuration. Never include service-account credentials or passwords. iOS requires its own registered Firebase app ID.

The gate blocks missing configuration, initialization errors, stream errors, null sessions and anonymous users. Firebase persists the session. Sign out destroys the authenticated navigator and all pushed routes. Client authentication does not replace server-side verification of Firebase ID tokens.

Verification: flutter analyze --no-fatal-infos; flutter test; flutter build apk --debug. Real production login, logout, revoked credentials and device testing remain required before production acceptance. The missing-configuration widget test verifies fail-closed UI behavior without claiming a live Firebase login.

References:
https://firebase.google.com/docs/flutter/setup
https://firebase.google.com/docs/auth/flutter/start
