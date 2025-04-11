import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(WeatherCityApp());
}

class WeatherCityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Weather',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.red),
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String city = 'London';
  double? temperature;
  double? windSpeed;
  String? condition;
  bool isLoading = false;

  final TextEditingController cityController = TextEditingController();

  Future<void> fetchWeather(String cityName) async {
    setState(() => isLoading = true);
    final apiKey = 'd35f5586115948a8b40120017251004';
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        setState(() {
          city = data['location']['name'];
          temperature = current['temp_c'];
          windSpeed = current['wind_kph'];
          condition = current['condition']['text'];
        });
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching weather.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildWeatherCard(String title, String value) {
    return Card(
      elevation: 3,
      color: Colors.red.shade50,
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather by City'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchWeather(cityController.text);
              },
              child: Text('Get Weather'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : temperature != null
                    ? Column(
                        children: [
                          Text(
                            'Weather in $city',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          buildWeatherCard('Temperature', '$temperature °C'),
                          buildWeatherCard('Condition', '$condition'),
                          buildWeatherCard('Wind Speed', '$windSpeed kph'),
                        ],
                      )
                    : Text('Enter a city to check weather.'),
          ],
        ),
      ),
    );
  }
}
