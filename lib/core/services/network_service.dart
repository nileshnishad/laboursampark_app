import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../env.dart';

class NetworkService {
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final host = Uri.parse(Env.baseUrl).host;
      final lookupResult = await InternetAddress.lookup(host);
      return lookupResult.isNotEmpty && lookupResult.first.rawAddress.isNotEmpty;
    } catch (_) {
      // On desktop, connectivity_plus can report a connection while DNS fails.
      // Fall back to allowing the app request path to surface the real error.
      return true;
    }
  }
}
