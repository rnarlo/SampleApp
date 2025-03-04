// Written by Christoper Marlo Jimenez
// 03/04/2025
//
// This file contains the store configuration.
//
// Based on the following documentations:
// https://pub.dev/documentation/flutter_redux/latest/
// https://pub.dev/documentation/redux/latest/

import '../api/person.dart';

// This class holds the application state.
class AppState {
  final List<Person> persons;
  final bool isLoading;
  final bool hasMoreData;
  final int fetchAttempts;

  AppState({
    required this.persons,
    required this.isLoading,
    required this.hasMoreData,
    required this.fetchAttempts,
  });

  AppState.initial()
    : persons = [],
      isLoading = true,
      hasMoreData = true,
      fetchAttempts = 0;

  AppState copyWith({
    List<Person>? persons,
    bool? isLoading,
    bool? hasMoreData,
    int? fetchAttempts,
  }) {
    return AppState(
      persons: persons ?? this.persons,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      fetchAttempts: fetchAttempts ?? this.fetchAttempts,
    );
  }
}
