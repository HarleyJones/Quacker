import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:socks5_proxy/socks_client.dart';

class AppHttpClient {

  static IOClient? _ioClient;

  static void setProxy(String? proxy) {
    if (proxy?.isEmpty ?? true) {
      _ioClient = null;
      return;
    }
    Uri uri = Uri.parse(proxy!);
    HttpClient httpClient;
    if (uri.scheme == 'socks5') {
      httpClient = HttpClient();
      String? username;
      String? password;
      if (uri.userInfo.isNotEmpty) {
        List<String> userPwdLst = uri.userInfo.split(':');
        username = userPwdLst[0];
        if (userPwdLst.length > 1) {
          password = userPwdLst[1];
        }
      }
      SocksTCPClient.assignToHttpClient(httpClient, [
        ProxySettings(InternetAddress(uri.host), uri.port, username: username, password: password),
      ]);
    }
    else if (uri.scheme.isEmpty || uri.scheme == 'http' || uri.scheme == 'https') {
      httpClient = HttpClient();
      httpClient.findProxy = (Uri url) {
        String foundProxy = HttpClient.findProxyFromEnvironment(url, environment: {"https_proxy": proxy});
        return foundProxy;
      };
    }
    else {
      throw Exception('Uri scheme ${uri.scheme} not implemented.');
    }
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    _ioClient = IOClient(httpClient);
  }

  static Future<http.Response> httpGet(Uri url, {Map<String,String>? headers}) async {
    if (_ioClient != null) {
      return _ioClient!.get(url, headers: headers);
    }
    else {
      return http.get(url, headers: headers);
    }
  }

  static Future<http.Response> httpPost(Uri url, {Map<String,String>? headers, Object? body, Encoding? encoding}) async {
    if (_ioClient != null) {
      return _ioClient!.post(url, headers: headers, body: body, encoding: encoding);
    }
    else {
      return http.post(url, headers: headers, body: body, encoding: encoding);
    }
  }

  static Future<http.StreamedResponse> httpSend(http.Request request) async {
    if (_ioClient != null) {
      return _ioClient!.send(request);
    }
    else {
      http.Client baseClient = http.Client();
      return baseClient.send(request);
    }
  }

}
