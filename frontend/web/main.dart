import 'dart:html';

import 'package:angular/angular.dart';
import 'package:frontend/app_component.template.dart' as ng;

void main() {
  _updateBackgroundImage();
  runApp(ng.AppComponentNgFactory);
  window.onResize.listen((_) => _updateBackgroundImage());
}

void _updateBackgroundImage() {
  int innerHeight = (window.innerHeight * window.devicePixelRatio).round();
  String suffix;
  if (innerHeight >= 2010) {
    suffix = "@1x";
  } else if (innerHeight >= 1005) {
    suffix = "@0.5x";
  } else if (innerHeight >= 603) {
    suffix = "@0.3x";
  } else {
    suffix = "@0.2x";
  }
  document.body.style.backgroundColor = "black";
  document.body.style.backgroundImage =
      "url(images/Balaton_Hungary_Landscape$suffix.jpg)";
}
