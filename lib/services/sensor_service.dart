import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  // Accelerometer data stream
  Stream<AccelerometerEvent> get accelerometerStream => 
      accelerometerEvents.throttleTime(Duration(milliseconds: 500));
  
  // Gyroscope data stream
  Stream<GyroscopeEvent> get gyroscopeStream => 
      gyroscopeEvents.throttleTime(Duration(milliseconds: 500));
  
  // User activity detection
  Stream<String> get userActivityStream => 
      Stream.periodic(Duration(minutes: 1)).asyncMap((_) => _detectActivity());
  
  // Simulate activity detection based on sensor data
  Future<String> _detectActivity() async {
    // This would normally use machine learning to analyze sensor patterns
    // For demo, we're returning random activities
    final activities = [
      'walking',
      'running',
      'still',
      'in_vehicle',
      'on_bicycle',
    ];
    
    return activities[DateTime.now().second % activities.length];
  }
}

// Extension to add throttling to sensor streams
extension ThrottleStreamExtension<T> on Stream<T> {
  Stream<T> throttleTime(Duration duration) {
    return transform(StreamTransformer.fromBind((Stream<T> stream) {
      StreamController<T> controller = StreamController<T>();
      T? lastEvent;
      DateTime? lastTime;
      
      stream.listen(
        (T event) {
          final now = DateTime.now();
          if (lastTime == null || now.difference(lastTime!) > duration) {
            controller.add(event);
            lastTime = now;
            lastEvent = event;
          } else {
            lastEvent = event;
            Future.delayed(duration - now.difference(lastTime!)).then((_) {
              if (lastEvent == event) {
                controller.add(event);
                lastTime = DateTime.now();
              }
            });
          }
        },
        onError: controller.addError,
        onDone: controller.close,
      );
      
      return controller.stream;
    }));
  }
}
