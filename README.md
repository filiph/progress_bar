Instructions


To build the ancient `frontend/`, [download Dart 2.0](https://dart.dev/get-dart/archive) and use it for `pub get` and then:

```sh
cd frontend
pub run build_runner build --release -o web:../gae/static_dart_build
```

