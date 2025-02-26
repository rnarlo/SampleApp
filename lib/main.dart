// Written by Christoper Marlo Jimenez
// 02/26/2025

import 'package:flutter/material.dart';
import 'package:sample_app/color_palette.dart';
import 'package:sample_app/api/person.dart';
import 'package:sample_app/details_page.dart';
import 'package:flutter/foundation.dart';

// Entry point of the application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDAX Sample App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorPalette.primary),
      ),
      home: const PDAXSampleApp(title: 'PDAX Sample App'),
      // Hide the debug banner.
      debugShowCheckedModeBanner: false,
    );
  }
}

class PDAXSampleApp extends StatefulWidget {
  const PDAXSampleApp({super.key, required this.title});
  final String title;

  @override
  State<PDAXSampleApp> createState() => _PDAXSampleAppState();
}

class _PDAXSampleAppState extends State<PDAXSampleApp> {
  final List<Person> _persons =
      []; // All the persons fetched from the Fake API.
  final ScrollController _scrollController = ScrollController();
  int _fetchAttempts = 0; // To limit the number of attempts to 4.
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchPersons();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMoreData &&
        !kIsWeb) {
      _fetchPersons();
    }
  }

  Future<void> _fetchPersons() async {
    if (_fetchAttempts > 4) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _fetchAttempts++;
    });

    try {
      final newPersons = await fetchPersons(10);
      setState(() {
        _persons.addAll(newPersons);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
    }
  }

  // Helper function to refresh the app.
  Future<void> _refreshApp() async {
    setState(() {
      // Reset everything.
      _persons.clear();
      _fetchAttempts = 0;
      _hasMoreData = true;
    });

    // Initialize first 10 persons again.
    await _fetchPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshApp,
            tooltip: 'Refresh the app.',
            color: ColorPalette.primary,
          ),
          SizedBox(width: 16.0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshApp,
        child:
            _persons.isEmpty && !_isLoading
                ? Center(
                  child: Text(
                    'Something went wrong. Perhaps there are no persons available.',
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _persons.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _persons.length) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            // If using a web browser, show a button to load more persons.
                            kIsWeb && !_isLoading && _hasMoreData
                                ? ElevatedButton(
                                  onPressed: _fetchPersons,
                                  child: Text("Load More"),
                                )
                                : SizedBox.shrink(),

                            _isLoading
                                ? CircularProgressIndicator()
                                : SizedBox.shrink(),

                            _hasMoreData
                                ? SizedBox.shrink()
                                : Text("No more persons available."),
                            SizedBox(height: 10.0),
                          ],
                        ),
                      );
                    }
                    return ListTile(
                      // I couldn't' get the image to load. Trying to manually open the url in a browser returns nothing.
                      title: Text(
                        "${_persons[index].firstname} ${_persons[index].lastname}",
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorPalette.primary,
                        ),
                      ),
                      subtitle: Text(
                        _persons[index].email,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: ColorPalette.secondary,
                        size: 24.0,
                        semanticLabel: 'Expand the details.',
                      ),
                      // When list tile is tapped, navigate to the details page with the according person's details.
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DetailsPage(person: _persons[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}
