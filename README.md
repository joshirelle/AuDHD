name: kiko_app
description: A pediatric screening and behavior tracking app for Pinoy families.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management & Storage
  provider: ^6.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Security & Biometrics
  local_auth: ^2.3.0
  flutter_secure_storage: ^9.2.2

  # PDF Generation
  pdf: ^3.11.1
  printing: ^5.13.1

  # UI Helper
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.10

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/json/

  fonts:
    - family: Fredoka
      fonts:
        - asset: assets/fonts/Fredoka-Bold.ttf
          weight: 700
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
        - asset: assets/fonts/Nunito-Regular.ttf
          weight: 400