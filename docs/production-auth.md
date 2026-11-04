# Production authentication

## Current source behavior

The active Flutter source contains `ProductionAuthGate` in `lib/production_auth.dart`.

- In debug mode, the app opens the development UI unless `requireAuthentication: true` is explicitly used by a test.
- In non-debug builds, the app routes through Firebase initialization and email/password authentication.
- The gate fails closed when required Firebase values are missing, initialization fails, the auth stream errors, the session is null or the user is anonymous.
- Authenticated routes are placed under a user-keyed Navigator so signing out disposes the authenticated route stack.
- Client-side Firebase authentication does not replace server-side verification of Firebase ID tokens.

Required Dart defines: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`. Do not commit service-account credentials, passwords or private server credentials.

## Current verification status

Widget coverage verifies that the production gate remains blocked without Firebase configuration and that debug mode opens the development UI. This is code/test evidence only.

A live Firebase project configuration, Email/Password provider setup, real user login/logout, revoked credentials and Galaxy A11 authentication behavior have not been verified in the current checkpoint. Production authentication is therefore **NOT ACCEPTED**.

## Required production verification

1. Register the actual Android application ID `com.pyincc.fashionai` in the intended Firebase project.
2. Enable Email/Password authentication.
3. Supply only the required Firebase client configuration through the supported Dart-define mechanism.
4. Test successful login, invalid credentials, network failure, sign-out, revoked credentials and a null/expired session on a real device.
5. Verify server-side Firebase ID-token validation wherever protected backend data is introduced.

References:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/start
