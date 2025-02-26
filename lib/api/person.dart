import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

// This is the Person class.
class Person {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final DateTime birthday;
  final String gender;
  final Map<String, dynamic> address;
  final String website;
  final Uri image;

  Person({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.birthday,
    required this.gender,
    required this.address,
    required this.website,
    required this.image,
  });

  // This is a factory constructor that creates a Person object given a JSON.
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      birthday: DateTime.parse(json['birthday']),
      gender: json['gender'],
      address: {
        'id': json['address']['id'],
        'street': json['address']['street'],
        'streetName': json['address']['streetName'],
        'buildingNumber': json['address']['buildingNumber'],
        'city': json['address']['city'],
        'zipcode': json['address']['zipcode'],
        'country': json['address']['country'],
        'country_code': json['address']['country_code'],
        'latitude': json['address']['latitude'],
        'longitude': json['address']['longitude'],
      },
      website: json['website'],
      image: Uri.parse(json['image']),
    );
  }
}

// Function to fetch person from the Fake API.
// It has a parameter quantity to specify the number of persons to fetch from the API.
Future<List<Person>> fetchPersons(int quantity) async {
  final response = await http.get(
    Uri.parse('https://fakerapi.it/api/v2/persons?_quantity=$quantity'),
  );

  if (response.statusCode == 200) {
    // print(response.body);
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    // print(jsonResponse);
    List<dynamic> personsData = jsonResponse['data'];
    return personsData.map((person) => Person.fromJson(person)).toList();
  } else {
    throw Exception('Something went wrong. Could not fetch persons.');
  }
}
