# Zambia Sign Language Hub

An offline-first Android app to help deaf and hard-of-hearing users in Zambia
learn sign language. Stage 1: a welcome screen and an offline dictionary of
signs with step-by-step images, descriptions, and example sentences.

**Everything works with no internet connection.** All images and data are
bundled inside the app at build time — nothing is downloaded at runtime.

## Getting started (development)

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel).
2. Install Android Studio (or just the Android SDK + an emulator/device).
3. From the project root:
   ```
   flutter pub get
   flutter run
   ```
4. To build a release APK to share for testing:
   ```
   flutter build apk --release
   ```
   The APK will be at `build/app/outputs/flutter-apk/app-release.apk` —
   this can be side-loaded onto any Android phone without the Play Store.

## Adding new signs (no coding required)

All dictionary content lives in **`assets/data/words.json`**. To add a sign:

1. Add your image(s) to `assets/images/<category_folder>/`.
   - Use lowercase, underscore-separated file names, e.g. `thank_you_1.jpg`.
   - Recommended: 3:4 or 4:3 aspect ratio photos, good lighting, plain background.
   - You can add 1 image, or several (a "step sequence" showing the motion),
     or a single short looping video later (video support is stubbed in the
     data model via the `"video"` field but not yet wired into the UI).
2. Add an entry to the `"entries"` array in `words.json`:
   ```json
   {
     "id": "thank_you",
     "word": "Thank you",
     "category": "Greetings",
     "description": "Flat hand starts at the chin, moves forward and down towards the person you are thanking.",
     "images": [
       "assets/images/greetings/thank_you_1.jpg"
     ],
     "video": null,
     "sentences": [
       "Thank you very much."
     ]
   }
   ```
3. Re-run `flutter pub get` if you added a brand-new category folder that
   isn't already listed under `flutter: assets:` in `pubspec.yaml`
   (all 23 planned categories are pre-registered there already, so this is
   usually not needed).

The `"category"` value must exactly match one of the strings in the
`"categories"` list at the top of `words.json`.

## Categories (stage 1)

Greetings, Family, Question Words, Food, Cooking, Work, Months,
Days and Time, Numbers, House, Making Plans, Weather,
Health and Well-being, Feeling, Adjectives, Bible, School, Verbs,
Places, Quantities, Comparisons, Colours, Prepositions.

## Project structure

```
lib/
  main.dart                      - app entry point, theme
  models/dictionary_entry.dart   - data model for one dictionary entry
  data/dictionary_repository.dart- loads & queries words.json
  screens/
    welcome_screen.dart          - stage 1 landing screen
    category_screen.dart         - category grid + search
    entry_list_screen.dart       - list of signs within a category
    entry_detail_screen.dart     - description, image steps, example sentences
assets/
  data/words.json                - all dictionary content (edit this to add signs)
  images/<category>/             - one folder per category, holds all images
```

## Roadmap ideas (not yet built)

- Video clip support in the detail screen for signs where motion is hard
  to capture in stills.
- Favorites / "words I'm learning" list.
- Quiz / practice mode.
- Search across sentences, not just word titles.
- A simple in-app way for community contributors to submit new signs.
