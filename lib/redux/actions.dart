// Written by Christoper Marlo Jimenez
// 03/04/2025
//
// This file contains the store actions.

import '../api/person.dart';

// Actions
// Instead of using an enum, we can use a class...

class FetchPersonsAction {}

// ...especially since FetchPersonsSuccessAction has to pass additional data, i.e. the list of persons.
class FetchPersonsSuccessAction {
  final List<Person> persons;
  FetchPersonsSuccessAction(this.persons);
}

class FetchPersonsFailureAction {
  FetchPersonsFailureAction() {
    print("Something went wrong. Could not fetch persons.");
  }
}

class RefreshPersonsAction {}
