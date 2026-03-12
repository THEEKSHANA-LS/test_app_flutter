import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_app/components/weather_item.dart';
import 'package:test_app/widgets/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();

  static const String API_KEY = "22c9f7c410504b0b82e83841260703";

  String location = "Colombo";
  String weatherIcon = "cloudy.png";
  int temperature = 0;
  int humidity = 0;
  int windSpeed = 0;
  int cloud = 0;
  String currentDate = "";

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = "";

  String searchWeatherAPI =
      "http://api.weatherapi.com/v1/forecast.json?key=$API_KEY&days=7&q=";

  @override
  void initState() {
    super.initState();
    fetchWeatherData("Colombo");
  }

  // Fetch weather data
  void fetchWeatherData(String city) async {
    try {
      var response = await http.get(Uri.parse(searchWeatherAPI + city));

      final weatherData = json.decode(response.body);

      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData['name']);

        var parsedDate =
            DateTime.parse(locationData['localtime'].substring(0, 10));

        currentDate = DateFormat('EEE, MMM d').format(parsedDate);

        currentWeatherStatus = currentWeather['condition']['text'];

        weatherIcon =
            currentWeatherStatus.replaceAll(' ', '').toLowerCase() + ".png";

        temperature = currentWeather['temp_c'].round();
        humidity = currentWeather['humidity'].round();
        windSpeed = currentWeather['wind_kph'].round();
        cloud = currentWeather['cloud'].round();

        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
      });
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  // Short location name
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.length > 1) {
      return "${wordList[0]} ${wordList[1]}";
    } else {
      return wordList[0];
    }
  }

  // Bottom sheet for search
  void openSearchSheet() {
    _cityController.clear();

    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Search City",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter city name",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  fetchWeatherData(_cityController.text);
                  Navigator.pop(context);
                },
                child: const Text("Search"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(top: 70, left: 15, right: 15),
        color: _constants.primaryColor.withOpacity(.2),
        child: Column(
          children: [
            Container(
              height: size.height * .7,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: _constants.linearGradientBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(.6),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  /// TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Image.asset('assets/menu.png', width: 35),

                      Row(
                        children: [

                          Image.asset("assets/pin.png", width: 20),

                          const SizedBox(width: 5),

                          Text(
                            location,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            onPressed: openSearchSheet,
                          )
                        ],
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/profile.png",
                          width: 35,
                          height: 35,
                        ),
                      ),
                    ],
                  ),

                  /// WEATHER ICON
                  SizedBox(
                    height: 160,
                    child: Image.asset("assets/$weatherIcon"),
                  ),

                  /// TEMPERATURE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        temperature.toString(),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                      ),

                      Text(
                        "°",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    currentWeatherStatus,
                    style: const TextStyle(color: Colors.white70, fontSize: 20),
                  ),

                  Text(
                    currentDate,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const Divider(color: Colors.white70),

                  /// WEATHER DETAILS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      WeatherItem(
                        value: windSpeed,
                        unit: " km/h",
                        imageUrl: "assets/windspeed.png",
                      ),

                      WeatherItem(
                        value: humidity,
                        unit: "%",
                        imageUrl: "assets/humidity.png",
                      ),

                      WeatherItem(
                        value: cloud,
                        unit: "%",
                        imageUrl: "assets/cloud.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// HOURLY FORECAST
            Expanded(
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "Today",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      Text(
                        "Forecasts",
                        style: TextStyle(
                          color: _constants.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForecast.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {

                        String time =
                            hourlyWeatherForecast[index]['time'].substring(11,16);

                        String temp =
                            hourlyWeatherForecast[index]['temp_c'].round().toString();

                        String iconName =
                            hourlyWeatherForecast[index]['condition']['text']
                                .replaceAll(' ', '')
                                .toLowerCase() +
                                ".png";

                        return Container(
                          margin: const EdgeInsets.only(right: 15),
                          width: 65,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [

                              Text(time),

                              Image.asset(
                                "assets/$iconName",
                                width: 25,
                              ),

                              Text("$temp°"),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}