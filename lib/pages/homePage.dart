import 'package:flutter/material.dart';
import 'package:test_app/widgets/constants.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();

  static String API_KEY = "22c9f7c410504b0b82e83841260703"; //api key for openweathermap...

  String location = "Asia/Colombo";
  String weatherIcon = "heavycloudy.png";
  int temparature = 0;
  int humidity = 0;
  int windSpeed = 0;
  int cloud = 0;
  String currentDate = "";

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = "";

  //api call...
  String searchWeatherAPI = "http://api.weatherapi.com/v1/current.json?key=" + API_KEY + "&days=7&q=";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top:70, left:10, right:10),
      )
    )

  }
}

