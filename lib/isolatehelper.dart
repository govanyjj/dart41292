import 'dart:async';
import 'dart:isolate';

class Logic {
  final SendPort sendPort;
  Logic(this.sendPort) {
    if (sendPort != null) {
      ReceivePort receivePort = ReceivePort();
      StreamSubscription listen;
      listen = receivePort.listen((data) {
        prereceiveLogic(data);
      });
    }
  }
  prereceiveLogic(dynamic data) {
    print(data);
  }

  static createLogic(SendPort sender) {
    return Logic(sender);
  }
}

class MainHub {
  Map<int, dynamic> controls = {};
  start() {
    for (var i = 0; i < 20; i++) {
      createIsoalte(i);
    }
  }

  sendMessage(String message) {
    if (controls != null && controls.length > 0) {
      controls.forEach((key, item) {
        item['receivePort'].sendPort.send(message);
      });
    }
  }

  Future createIsoalte(int i) async {
    int begin = DateTime.now().millisecondsSinceEpoch;
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
        Logic.createLogic, receivePort.sendPort,
        debugName: "${i}logic");
    print(
        "create isolate finish cost time ${DateTime.now().millisecondsSinceEpoch - begin}");

    if (controls.containsKey(i)) {
      controls[i]['isolate'].kill(priority: Isolate.immediate);
      controls[i] = {
        "receivePort": receivePort,
        "isolate": isolate,
      };
    } else {
      controls.putIfAbsent(
          i,
          () => {
                "receivePort": receivePort,
                "isolate": isolate,
              });
    }
  }
}
