# Android cheat sheet

- [Change the app icon](#change-the-app-icon)
- [View & debug shared preferences (local storage)](#view-and-debug-shared-preference)

## Change the app icon

You will use a tool in Android Studio, called **Image Asset Studio**, to generate different versions of the launcher icons.

Open the repo folder in Android Studio, then switch to **Project** view

<img src="https://developer.android.com/static/codelabs/basic-android-kotlin-compose-training-change-app-icon/img/60dc4d35adaef95e_1920.png" width="200" />

Locate `android/app/src/main/res` and right click on `res/` folder, then `New > Image Asset`. Change the `Path` to the new icon image file then Asset Studio will automatically generate all versions for icons. See [the codelab guide](https://developer.android.com/codelabs/basic-android-kotlin-compose-training-change-app-icon?hl=en#4) for more details.

<img src="https://developer.android.com/static/codelabs/basic-android-kotlin-compose-training-change-app-icon/img/a02f2b23afa5a9e2_1920.png" width="500" />

## View and debug shared preference

To view or debug local storage data (via `SharedPreferences` library), open **Android Studio** > ***Device Explorer*** > `data/data/com.redflags.app/FlutterSharedPreferences.xml`.

<img src="./device-explorer.png" width="200px" />
<img src="./shared-preferences.png" width="540px" />
