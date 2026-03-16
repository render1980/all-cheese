# all_cheese

Digital version of the original 'Alles käse' card board game.

## Prerequisites for development

[Flutter](https://docs.flutter.dev/get-started/install)

## Build

```
flutter pub get
flutter pub run build_runner build
```

## Run and connect to Android emulator

```
flutter emulators --launch Medium_Phone_API_36.0
flutter run --debug
```

## Run and connect to Chrome

```
flutter build web
flutter run -d chrome
```
