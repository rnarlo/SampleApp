// Written by Christoper Marlo Jimenez
// 02/26/2025

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sample_app/color_palette.dart';
import 'package:sample_app/details_page.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'redux/actions.dart';
import 'redux/reducer.dart';
import 'redux/store.dart';

// Entry point of the application.
void main() {
  // We initialize the Redux store.
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [fetchPersonsMiddleware],
  );

  runApp(PDAXApp(store: store));
}

class PDAXApp extends StatelessWidget {
  final Store<AppState> store;

  const PDAXApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'PDAX Sample App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ColorPalette.primary),
        ),
        home: PDAXSampleApp(title: 'PDAX Sample App'),
        debugShowCheckedModeBanner: false,
      ),
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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Initialize the scroll controller.
    _scrollController = ScrollController()..addListener(_scrollListener);

    // Fetch the first 10 persons on app start by invoking FetchPersonsAction().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreProvider.of<AppState>(
        context,
        listen: false,
      ).dispatch(FetchPersonsAction());
    });
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final store = StoreProvider.of<AppState>(context, listen: false);
    final state = store.state;

    // Instead of just _isLoading, _hasMoreData, etc., we now use the store. These are initalized in store.dart.
    // This will be true for the whole codebase.
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        state.hasMoreData &&
        state.isLoading &&
        !kIsWeb) {
      store.dispatch(FetchPersonsAction());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        final store = StoreProvider.of<AppState>(context, listen: false);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  store.dispatch(RefreshPersonsAction());
                  store.dispatch(FetchPersonsAction());
                },
                tooltip: 'Refresh the app.',
                color: ColorPalette.primary,
              ),
              SizedBox(width: 16.0),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              store.dispatch(RefreshPersonsAction());
              store.dispatch(FetchPersonsAction());
            },
            child:
                state.persons.isEmpty && !state.isLoading
                    ? Center(
                      child: Text(
                        'Something went wrong. Perhaps there are no persons available.',
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: state.persons.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.persons.length) {
                          return Center(
                            child: Column(
                              children: [
                                SizedBox(height: 10.0),
                                // If using a web browser, show a button to load more persons.
                                kIsWeb &&
                                        state.hasMoreData &&
                                        state.persons.isNotEmpty
                                    ? ElevatedButton(
                                      onPressed: () {
                                        store.dispatch(FetchPersonsAction());
                                      },
                                      child: Text("Load More"),
                                    )
                                    : SizedBox.shrink(),

                                // Somehow bugged and isLoading is always true.
                                // TODO: Fix isLoading bug
                                !kIsWeb && state.isLoading && state.hasMoreData
                                    ? CircularProgressIndicator()
                                    : SizedBox.shrink(),

                                !state.hasMoreData
                                    ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("No more persons available."),
                                    )
                                    : SizedBox.shrink(),

                                SizedBox(height: 10.0),
                              ],
                            ),
                          );
                        }
                        return ListTile(
                          // I couldn't' get the image to load. Trying to manually open the url in a browser returns nothing.
                          title: Text(
                            "${state.persons[index].firstname} ${state.persons[index].lastname}",
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorPalette.primary,
                            ),
                          ),
                          subtitle: Text(
                            state.persons[index].email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: ColorPalette.secondary,
                            size: 24.0,
                            semanticLabel: 'Expand the details.',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailsPage(
                                      person: state.persons[index],
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        );
      },
    );
  }
}
