## Game and project name

All cheese

## Technologies used for implementation

Flutter

## Game rules

Are described in file /home/db/Dropbox/other/rules_cheesy.pdf

## Requirements

Build a cross-platform game that runs on web, android and ios platforms.
You can check project in /home/db/go/src/cheesy folder that is written in pure js to understand main mechanics. Bear in mind that this project contains some bugs.

Background of field: yellow
36 cards in total

card front side:
- 18 cards with mouse + cheese
- 18 cards with mouse traps
card back side:
- from 1 to 6 cheese holes

dice

Search web for nice images to be used for cards and dice. Beautiful animations are welcome,


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
