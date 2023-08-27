# Flutter cheat sheet

- [Sync Firebase configuration](#sync-firebase-configuration)

## Sync Firebase configuration

Whenever you change **Firebase** project settings or iOS/Android app settings you can run `flutterfire configure` command to sync and update your repo configuration files. Note that you will need to log in **Firebase CLI** first.

```bash
$ firebase login
```

then 

```bash
flutterfire configure
```