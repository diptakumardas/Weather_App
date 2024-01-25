import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/additional_info.dart';
import 'package:weather/weather_forcast.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  //API
  /*void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentWeather();
  }*/

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final result = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=7bb4f75e33ed2a0e4dbe90b913d53010"));
      final data = jsonDecode(result.body);

      if (data['cod'] != "200") {
        throw "error occared";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {
            setState(() {

            });
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData["main"]['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final pressure = currentWeatherData['main']['pressure'];
          final windSpeed = currentWeatherData['wind']['speed'];
          final humidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Main Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "${(currentTemp-273.15).toStringAsFixed(2)}°C",
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Icon(
                                currentSky == "Clouds" || currentSky == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 60,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                currentSky,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Weather Forcast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                //Weather Card

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      itemCount: 39,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context,index){
                        final hourlyForecast = data['list'][index+1];
                        final  hourlySky = hourlyForecast['weather'][0]['main'];
                        final hourlyTemp = double.parse(hourlyForecast['main']['temp'].toString());
                        final time = DateTime.parse(hourlyForecast["dt_txt"]);
                        return HourlyUpdate(time: DateFormat.j().format(time),
                            icon: hourlySky ==
                                'Clouds' ? Icons.cloud :
                            hourlySky ==
                                'Rain'
                                ? Icons.thunderstorm
                                : Icons.sunny,
                            temp: (hourlyTemp-273.15).toStringAsFixed(2)
                            // (number * 100).truncateToDouble() / 100;
                            //${(currentTemp-273.15).toStringAsFixed(2)}°C
                        );


                  }
                  ),
                ),

                //additional card
                 const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfo(
                        icon: Icons.water_drop,
                        label: "Humedity",
                        value: humidity.toString()),
                    AdditionalInfo(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: windSpeed.toString()),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: pressure.toString(),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
