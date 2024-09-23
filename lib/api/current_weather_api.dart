import 'package:dio/dio.dart';
import 'package:sky_cast/model/current_weather.dart';
import 'package:sky_cast/model/day_and_3_hour_weather_model.dart';

class WeatherApi {
  final Dio dio = Dio();
  final String apiKey = "cbec3f9f25a81838bcbdfcba21799aa8";

  Future<WeatherResponse?> currentWeather(double lat, double lon) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final weatherData = WeatherResponse.fromJson(response.data);
        return weatherData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<DayAnd3HourWeatherModel?> dayAndHourWeatherData(double lat, double lon) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/forecast",
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final weatherData = DayAnd3HourWeatherModel.fromJson(response.data);
        return weatherData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<WeatherResponse?> currentWeatherByZip(String zipCode) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/weather?zip=$zipCode,in&appid=$apiKey",

      );

      if (response.statusCode == 200) {
        final weatherData = WeatherResponse.fromJson(response.data);
        return weatherData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<DayAnd3HourWeatherModel?> dayAndHourWeatherDataByZip(String zipCode) async {
    try {
      final response = await dio.get(
        "https://api.openweathermap.org/data/2.5/forecast?zip=$zipCode,in&appid=$apiKey",
      );

      if (response.statusCode == 200) {
        final weatherData = DayAnd3HourWeatherModel.fromJson(response.data);
        return weatherData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

