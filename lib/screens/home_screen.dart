import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sky_cast/api/current_weather_api.dart';
import 'package:sky_cast/model/current_weather.dart';
import 'package:sky_cast/model/day_and_3_hour_weather_model.dart';
import 'package:sky_cast/theme/text-style.dart';
import 'package:sky_cast/widget/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherResponse? _weatherResponse;
  DayAnd3HourWeatherModel? _dayAnd3HourWeatherModel;
  bool _isLoading = true;
  String? _errorMessage;
  final WeatherApi _weatherApi = WeatherApi();

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }
  bool isSearch = false;

  Future<void> _fetchWeatherData({String? zipCode}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      WeatherResponse? weather;
      DayAnd3HourWeatherModel? dayAndHourWeather;

      if (zipCode != null && zipCode.isNotEmpty) {
        weather = await _weatherApi.currentWeatherByZip(zipCode);
        dayAndHourWeather = await _weatherApi.dayAndHourWeatherDataByZip(zipCode);
      } else {
        Position? position;
        PermissionStatus status = await Permission.location.request();
        if (status.isGranted) {
          position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        }

        double lat = position?.latitude ?? 25.043966;
        double lon = position?.longitude ?? 73.899923;

        weather = await _weatherApi.currentWeather(lat, lon);
        dayAndHourWeather = await _weatherApi.dayAndHourWeatherData(lat, lon);
      }

      if (weather != null && dayAndHourWeather != null) {
        setState(() {
          _weatherResponse = weather;
          _dayAnd3HourWeatherModel = dayAndHourWeather;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch weather data.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching weather data: ${e.toString()}';
      });
    }
  }

  void _searchWeatherByZipCode(String zipCode) {
    if (zipCode.isNotEmpty) {
      _fetchWeatherData(zipCode: zipCode);
      setState(() {
        isSearch = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid ZIP code.';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingScreen()
          : _errorMessage != null
          ? _buildErrorScreen()
          : _buildWeatherContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xff1c1973),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'An error occurred.',
              style: customTextStyle(fontSize: 16, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherContent() {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.8,
          
          child: Image.asset("assets/images/bg-image2.jpg",fit: BoxFit.cover,),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            CustomAppBar(
            weatherResponse: _weatherResponse,
            isLoading: _isLoading,
            onSearch: _searchWeatherByZipCode,
          ),
              const SizedBox(height: 20),
              weatherDetail(),
            ],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.47,
          minChildSize: 0.47,
          maxChildSize: 0.88,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xff1c1973),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: customDraggableData(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget customDraggableData() {
    if (_dayAnd3HourWeatherModel == null) return Container();
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<ListElement> todayWeatherData = _dayAnd3HourWeatherModel!.list!.where((element) {
      String weatherDate = DateFormat('yyyy-MM-dd').format(element.dtTxt!);
      return weatherDate == todayDate;
    }).toList();

    Map<String, List<ListElement>> groupedWeatherData = {};
    for (var item in _dayAnd3HourWeatherModel!.list!) {
      String date = DateFormat('yyyy-MM-dd').format(item.dtTxt!);
      if (groupedWeatherData[date] == null) {
        groupedWeatherData[date] = [];
      }
      groupedWeatherData[date]!.add(item);
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xffcacaca),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 26.0),
              child: Text("Hourly Forecast", style: customTextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: todayWeatherData.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (BuildContext context, int index) {
                  final hourlyData = todayWeatherData[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: hourlyForecastComponent(
                      iconCode: hourlyData.weather.first.icon!,
                      temp: (hourlyData.main!.temp! - 273.15).toStringAsFixed(1),
                      time: DateFormat.jm().format(hourlyData.dtTxt!),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 26.0),
              child: Text("Next Forecast", style: customTextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12,),
            ListView.builder(
              padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: groupedWeatherData.keys.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index){
                  String date = groupedWeatherData.keys.elementAt(index);
                  List<ListElement> dailyWeatherData = groupedWeatherData[date]!;
                  ListElement firstEntry = dailyWeatherData.first;
                  String dayName = DateFormat('EEEE').format(firstEntry.dtTxt!);
                  String formattedDate = DateFormat('MMM d').format(firstEntry.dtTxt!);
                  String temp = (firstEntry.main!.temp! - 273.15).toStringAsFixed(0);
                  String? main = firstEntry.weather.first.main;
                  String iconUrl = "http://openweathermap.org/img/wn/${firstEntry.weather.first.icon}@2x.png";
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xff0f0f31).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15)
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayName,style: customTextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.w500),),
                        Text(formattedDate,style: customTextStyle(fontSize: 11, color: const Color(0xffb2b1c1),fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text("$temp°C",style: customTextStyle(fontSize: 38, color: const Color(0xffffffff),fontWeight: FontWeight.w500)),
                    Column(
                      children: [
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: 80,
                          height: 50,
                          imageUrl: iconUrl,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        Text("$main",style: customTextStyle(fontSize: 12, color: const Color(0xffffffff),fontWeight: FontWeight.w500),)
                      ],
                    ),

                  ],
                ),
              );
            })

          ],
        ),
      ],
    );
  }

  Widget hourlyForecastComponent({required String iconCode, required String time, required String temp}) {
    return Column(
      children: [
         CircleAvatar(
           backgroundColor: Colors.white.withOpacity(0.3),
          radius: 24,

          child: Center(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              imageUrl: "http://openweathermap.org/img/wn/$iconCode@2x.png",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        const SizedBox(height: 6,),

        Text(time, style: customTextStyle(fontSize: 11, color: const Color(0xffb2b1c1))),
        Text("23°", style: customTextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget weatherDetail() {
    if (_weatherResponse == null) return Container();
    final temp = _weatherResponse!.main.temp.toInt() - 273.15;
    final minTemp = (_weatherResponse!.main.tempMin.toInt() - 273.15).toInt();
    final maxTemp = (_weatherResponse!.main.tempMax.toInt() - 273.15).toInt();
    final feelTemp = (_weatherResponse!.main.feelsLike.toInt() - 273.15).toInt();
    final iconCode = _weatherResponse!.weather.first.icon;
    final visibility = _weatherResponse!.visibility / 1000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today, ${_formatDateTime(_weatherResponse!.dt)}", style: customTextStyle(fontSize: 12, color: Colors.white)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${temp.toInt()}",
                    style: GoogleFonts.manrope(fontSize: 100, color: Colors.white, fontWeight: FontWeight.w500, height: 1),
                  ),
                  Text(
                    "°c",
                    style: customTextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      imageUrl: "http://openweathermap.org/img/wn/$iconCode@2x.png",
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _weatherResponse!.weather.first.description,
                      style: customTextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text("$maxTemp° / $minTemp° Feels like $feelTemp°", style: customTextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white.withOpacity(0.1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      shortWeatherInfo(title: "${_weatherResponse!.main.humidity}%", subtitle: "Humidity"),
                      shortWeatherInfo(title: "${_weatherResponse!.wind.speed} km/h", subtitle: "Wind Speed"),
                      shortWeatherInfo(title: "${visibility.toStringAsFixed(1)} km", subtitle: "Visibility"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  Widget shortWeatherInfo({required String title, required String subtitle}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: customTextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          Text(subtitle, style: customTextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
        ],
      ),
    );
  }


}
