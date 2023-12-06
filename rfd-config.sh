#!/bin/sh

if [ ! -d "rfd-app-config" ]; then
    echo "[Error] Unable to find rfd-app-config folder!"
    echo "Please ensure you have add rfd-app-config repository as a submodule for setting up configuration."
    echo "e.g. git submodule add git@github.com:redflagsdating/rfd-app-config.git"
fi

if [ -z "$1" ] || [ "$1" != "cp" ] && [ "$1" != "ln" ] && [ "$1" != "ln -s" ] && [ "$1" != "rm" ]; then
    echo "Please specify commnd to setup config"
    echo "e.g. ./rfd-config.sh cp|ln|ln -s|rm"
    exit 1
fi

if [ "$1" == "rm" ]; then
    $1 .env.dev .env android/app/src/dev/google-services.json android/app/src/prod/google-services.json ios/config/dev/GoogleService-Info.plist ios/config/dev/firebase_app_id_file.json ios/config/prod/GoogleService-Info.plist ios/config/prod/firebase_app_id_file.json
else
    $1 rfd-app-config/dev/.env.dev .env.dev
    $1 rfd-app-config/prod/.env .env

    mkdir -p android/app/src/dev
    mkdir -p android/app/src/prod
    $1 rfd-app-config/dev/android/google-services.json android/app/src/dev/google-services.json
    $1 rfd-app-config/prod/android/google-services.json android/app/src/prod/google-services.json

    mkdir -p ios/config/dev
    mkdir -p ios/config/prod
    $1 rfd-app-config/dev/ios/GoogleService-Info.plist ios/config/dev/GoogleService-Info.plist
    $1 rfd-app-config/dev/ios/firebase_app_id_file.json ios/config/dev/firebase_app_id_file.json
    $1 rfd-app-config/prod/ios/GoogleService-Info.plist ios/config/prod/GoogleService-Info.plist
    $1 rfd-app-config/prod/ios/firebase_app_id_file.json ios/config/prod/firebase_app_id_file.json
fi