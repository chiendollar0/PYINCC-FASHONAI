# PYINCC FashionAI

Flutter application foundation for Android and iOS. The first deliverable is a **UI preview**, not a working face-swap, virtual try-on, checkout, or 3D engine.

**Product scope is locked in [docs/product-contract-v2.md](docs/product-contract-v2.md).** This README describes the current implementation, which is not yet compliant with the locked 3D/offline requirements.

## Product navigation

The default tab is **Studio**. Bottom navigation has exactly four destinations: **Studio**, **Home**, **Store**, **Account**.

- **Studio**: personal portrait selection, outfit selection, saved wardrobe, lightweight makeup (lipstick, eyeliner, mascara/lashes, blush), before/after UI and a future AI processing integration. Customers will be able to add their own garment photos.
- **Home**: model/avatar selection and optional height, weight and age settings.
- **Store**: real, verified products from participating sellers; users can send a selected item to Studio, save it and follow a verified seller purchase link. No fabricated prices, products or order statuses.
- **Account**: Firebase authentication, privacy settings, favorites and order links after integration.

The user-supplied model photographs are **visual references**; do not imply that an image generated with AI is a verified merchant listing.

## Privacy and safety

Local-first storage is the default. Optional encrypted cloud backup must be OFF until explicit opt-in. Obtain consent before processing portraits through a third-party provider. Only use faces the user has permission to use. Avatar proportions are approximate and should not be presented as accurate body measurements. Do not claim a garment will fit exactly.

## Development

Requires Flutter stable and an Android SDK and/or macOS with Xcode for iOS.

```sh
flutter create --platforms=android,ios --org com.pyincc --project-name pyincc_fashionai --no-pub .
flutter pub get
flutter analyze
flutter test
flutter run
```

For iOS on macOS, install Xcode and CocoaPods and open `ios/Runner.xcworkspace` if native project configuration is needed. An iOS release for a physical device requires Apple signing credentials and appropriate entitlements. Firebase and shopping provider credentials must be configured separately; do not commit secrets.

## Continuous integration

- `.github/workflows/android-apk.yml`: static analysis, tests, Android compile validation, then debug APK.
- `.github/workflows/ios-validation.yml`: macOS, Flutter tests and unsigned iOS **simulator** build.

A passing CI build is **not** evidence of a successful on-device launch or functioning AI. Test real devices and the full customer journey before releasing.

## Milestones

1. Fix and validate the four-tab Flutter foundation.
2. Implement the approved real-model Studio-first UI and image import/wardrobe locally.
3. Test navigation, image handling, permission flow, Android and iOS.
4. Integrate Firebase Authentication and explicit consent.
5. Integrate verified try-on AI, real merchant feeds, and external checkout.
