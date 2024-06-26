class Configurations {
  static const String apiKey = 'AIzaSyCT9JLWmEjGJ1Y32JrLacG2OQHcxF8DbfY';
  static const String authDomain = 'flixfive-5db87.firebaseapp.com';
  static const String databaseUrl = 'https://flixfive-5db87-default-rtdb.firebaseio.com';
  static const String projectId = 'flixfive-5db87';
  static const String storageBucket = 'flixfive-5db87.appspot.com';
  static const String messagingSenderId = '458530444305';
  static const String appId = '1:458530444305:web:c773f864b4c434e0c84db0';
  static const String measurementId = 'G-P18JL6JXEX';

  static Map<String, dynamic> get firebaseConfig => {
    'apiKey': apiKey,
    'authDomain': authDomain,
    'databaseURL': databaseUrl,
    'projectId': projectId,
    'storageBucket': storageBucket,
    'messagingSenderId': messagingSenderId,
    'appId': appId,
    'measurementId': measurementId,
  };
}
