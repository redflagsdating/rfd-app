# Firebase cheat sheet

- [Sync Firebase configuration](#sync-firebase-configuration)

## Sync Firebase configuration

Whenever you change **Firebase** project settings or iOS/Android app settings you can run `flutterfire configure` command to sync and update your repo configuration files. Note that you will need to log in **Firebase CLI** first.

```bash
firebase login
```

then

```bash
flutterfire configure
```

select `rfd-app-dev` to sync `dev` environment and `rfd-app-prod` for `prod` environment

```bash
? Select a Firebase project to configure your Flutter application with ›                                                                                        
❯ rf-app-dev-7145f (rfd-app-dev)          
  rfd-app-prod-1fdad (rfd-app-prod)                             
  <create a new project>  
```

copy the the generated files to the its corresponding path for `dev` or `prod`, see [Environments](./environments.md).