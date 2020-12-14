import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class WooService {
  Dio _dio;
  Dio dio;
  String secret = 'cs_7057f57735821c33960beb37dbd951e501501ccc';
  String key = 'ck_0a271ecb08de50800719c5f364fbc53e4a63890f';
  WooService() {
    _dio = new Dio();
    dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options) {
        options.queryParameters.addEntries([
          MapEntry(
              'consumer_key', 'ck_0a271ecb08de50800719c5f364fbc53e4a63890f'),
          MapEntry(
              'consumer_secret', 'cs_7057f57735821c33960beb37dbd951e501501ccc'),
        ]);
      },
    ));
    dio.interceptors.add(DioCacheManager(CacheConfig(
            baseUrl: "https://coderapps.xyz", maxMemoryCacheCount: 500))
        .interceptor);
  }

  getCategories() {
    String url =
        'https://coderapps.xyz/wp-json/wc/v3/products/categories?consumer_key=ck_0a271ecb08de50800719c5f364fbc53e4a63890f&consumer_secret=cs_7057f57735821c33960beb37dbd951e501501ccc&category=15';
    var response =
        _dio.get(url, options: Options(responseType: ResponseType.plain));
    return response;
  }
}

WooService woo = new WooService();
