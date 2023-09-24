# iOS cheat sheet

- [(Xcode) Change the app icon and launch screen](#change-the-app-icon-and-launch-screen)
- [(Xcode) Add/Remove dependency packages](#addremove-dependency-packages)

## Change the app icon and launch screen

1. Use [appiconmaker](https://appiconmaker.co/) or [Icon Set Creator](https://stackoverflow.com/questions/43928702/how-to-change-the-application-launcher-icon-on-flutter) to generate all versions of icon from the source image. For non-square image asset, use [Icon Slayer](https://www.gieson.com/Library/projects/utilities/icon_slayer/) instead with **SVG** file.

2. Open the repo folder in **Xcode**, then go to `Runner > Asset`

<img src="https://i.stack.imgur.com/lb9io.png" width="800px" />

3. Drag & drop the versions of icon accordingly to replace the icons (e.g. `Icon-40.png` should goes to `2x of 20pt`)

## Add/Remove dependency packages

Open **Xcode** and select ***Runner*** > ***PROJECT - Runner*** > ***Package Dependencies*** tab.

<img src="./xocde-package-dependency.png" width="800px" />