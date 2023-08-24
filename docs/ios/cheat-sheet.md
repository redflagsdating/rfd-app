# iOS cheat sheet

- [Change the app icon and launch screen](#change-the-app-icon-and-launch-screen)

## Change the app icon and launch screen

1. Use [appiconmaker](https://appiconmaker.co/) or [Icon Set Creator](https://stackoverflow.com/questions/43928702/how-to-change-the-application-launcher-icon-on-flutter) to generate all versions of icon from the source image.

2. Open the repo folder in **Xcode**, then go to `Runner > Asset`

![](https://i.stack.imgur.com/lb9io.png)

3. Drag & drop the versions of icon accordingly to replace the icons (e.g. `Icon-40.png` should goes to `2x of 20pt`)