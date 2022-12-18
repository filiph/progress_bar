## Frontend instructions


To build the ancient `frontend/`, [download Dart 2.0](https://dart.dev/get-dart/archive) and use it for `pub get` and then:

```sh
cd frontend
pub run build_runner build --release -o web:../gae/static_dart_build
```

## Backend instructions

We are still on Python 2.7, and we are using old versions of Mastodon, pytz, dateutil, and decorator downloaded from https://pypi.org/.


### Deployment

Go to `gae/` and run

```sh
gcloud app --project progressbarserver deploy
```
