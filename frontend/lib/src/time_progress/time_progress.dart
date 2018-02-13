import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'time-progress',
  styleUrls: const ['time_progress.css'],
  templateUrl: 'time_progress.html',
  directives: const [
    MaterialProgressComponent,
  ],
  providers: const [],

)
class TimeProgressComponent {
  @Input()
  String title = '';

  @Input()
  double value = 0.0;
}
