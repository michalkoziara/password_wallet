import 'package:http/http.dart';

/// An IP address provider.
class IpAddressProvider {
  /// Gets public IP address based on ipify.org result.
  Future<String> getPublicIpAddress() async {
    try {
      const String url = 'https://api.ipify.org';
      final Response response = await get(url);
      if (response.statusCode == 200) {
        // The response body is the IP in plain text, so just
        // return it as-is.
        return response.body;
      } else {
        // The request failed with a non-200 code
        // The ipify.org API has a lot of guaranteed uptime
        // promises, so this shouldn't ever actually happen.
        print(response.statusCode);
        print(response.body);
        return null;
      }
    } on Exception catch (exception) {
      // Request failed due to an error, most likely because
      // the phone isn't connected to the internet.
      print(exception);
      return null;
    }
  }
}
