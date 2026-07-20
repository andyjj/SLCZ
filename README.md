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

## Adding new signs

All dictionary content lives in **`assets/data/words.json`**, but you don't
need to hand-edit it. Instead:

1. Add your image(s) to `assets/images/<category_folder>/`.
   - Use lowercase, underscore-separated file names matching the word,
     e.g. `thank_you.jpg`.
   - Recommended: 3:4 or 4:3 aspect ratio photos, good lighting, plain background.
   - For a multi-step sign, number the images: `thank_you_1.jpg`,
     `thank_you_2.jpg`, `thank_you_3.jpg` — they'll show in that order as a
     swipeable sequence. A single un-numbered image (`smile.jpg`) is also fine.
   - Optionally, add a `thank_you_definition.txt` file in the same folder.
     Plain text becomes the entry's description as-is, or you can use this
     template with recognized section headers on their own line:
     ```
     Definition
     A general definition of the word (not currently shown in the app).

     Sign Description
     How to actually perform the sign — becomes the entry's description.

     Potential Sentences
     One example sentence per line — becomes the entry's example sentences.

     Notes
     Extra performance notes — appended to the description.
     ```
     No JSON editing needed either way. If the file is missing (or a
     section is blank), that field is left as-is — blank for a new entry,
     or whatever was already there if you'd written one by hand.
2. Run the sync script from the project root:
   ```
   dart run tool/sync_dictionary.dart
   ```
   This scans every category folder and creates or updates the matching
   entry in `words.json` automatically — grouping numbered images into a
   step sequence, and deriving the word's display name from the file name.
   It never deletes anything, and never overwrites a description or example
   sentences you've already written by hand.

   It also downscales and re-compresses any image over 1600px on its
   longest edge (a common size straight off a phone camera), so photos stay
   phone-friendly without you needing to resize them yourself. This
   overwrites the file in place — keep your own full-resolution originals
   somewhere else if you want to preserve them, since this step is lossy
   and one-way. Images already at or under 1600px are left untouched.
3. The script prints which entries still need a description and example
   sentence(s) — open `words.json` and fill those two fields in for each
   one it lists (`"description"` and `"sentences"`).

The category folder name must be one of the ones already in
`tool/sync_dictionary.dart`'s `categoryByFolder` map (all 23 planned
categories are already there).

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
