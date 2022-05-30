import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Code modified from https://github.com/yshean/google_places_flutter

// For storing our result
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  PlaceApiProvider(this.sessionToken);

  final String sessionToken;


  final String apiKey = dotenv.get('MAPS_KEY', fallback: '');

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&key=$apiKey&sessiontoken=$sessionToken');
    var response = await http.post(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<double>> getPlaceDetailFromId(String input) async {
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?fields=geometry/location&place_id=$input&types=address&key=$apiKey&sessiontoken=$sessionToken');
    var response = await http.post(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return [result['result']['geometry']['location']['lat'], result['result']['geometry']['location']['lng']];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

}
