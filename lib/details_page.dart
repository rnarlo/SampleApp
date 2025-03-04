import 'package:flutter/material.dart';
import 'package:sample_app/api/person.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sample_app/color_palette.dart';

class DetailsPage extends StatelessWidget {
  final Person person;
  const DetailsPage({Key? key, required this.person}) : super(key: key);

  // Helper function  building a visually appealing details view.
  // There is an optional parameter to handle links such as the website in the person's data'.
  Widget _buildRichText(String title, dynamic value, {bool isUri = false}) {
    return GestureDetector(
      onTap:
          isUri == true
              ? () async {
                final Uri url = Uri.parse(value);
                await launchUrl(url);
              }
              : null,
      child: RichText(
        text: TextSpan(
          text: '$title\n',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: '$value\n',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: isUri == true ? ColorPalette.primary : Colors.black87,
                decoration: isUri == true ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${person.firstname} ${person.lastname}")),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRichText('ID', person.id),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    final Uri url = Uri.parse(person.website);
                    launchUrl(url);
                  },
                  child: _buildRichText('Website', person.website, isUri: true),
                ),
                SizedBox(height: 10),
                _buildRichText('Gender', person.gender),
                SizedBox(height: 10),
                _buildRichText('Email', person.email, isUri: true),
                SizedBox(height: 10),
                _buildRichText('Phone', person.phone),
                SizedBox(height: 10),
                _buildRichText(
                  'Birthday',
                  DateFormat('MMMM dd, yyyy').format(person.birthday),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Address\n',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${person.address['street']}, '
                            '${person.address['streetName']}\n'
                            '${person.address['city']}, '
                            '${person.address['zipcode']}\n'
                            '${person.address['country']}\n'
                            'Latitude: ${person.address['latitude']}\n'
                            'Longitude: ${person.address['longitude']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
