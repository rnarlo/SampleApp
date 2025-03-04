// Written by Christoper Marlo Jimenez
// 03/04/2025
//
// This file contains the store actions.

import 'package:redux/redux.dart';
import 'store.dart';
import 'actions.dart';
import '../api/person.dart';

// Reducer

AppState appReducer(AppState state, dynamic action) {
  if (action is FetchPersonsAction) {
    // print("Test");
    return state.copyWith(isLoading: true);
  } else if (action is FetchPersonsSuccessAction) {
    return state.copyWith(
      persons: [...state.persons, ...action.persons],
      isLoading: false,
      fetchAttempts: state.fetchAttempts + 1,
      hasMoreData: state.fetchAttempts < 4,
    );
  } else if (action is FetchPersonsFailureAction) {
    return state.copyWith(isLoading: false, hasMoreData: false);
  } else if (action is RefreshPersonsAction) {
    return AppState.initial();
  }
  return state;
}

void fetchPersonsMiddleware(
  Store<AppState> store,
  action,
  NextDispatcher next,
) async {
  if (action is FetchPersonsAction) {
    try {
      final newPersons = await fetchPersons(10);
      store.dispatch(FetchPersonsSuccessAction(newPersons));
      // print(newPersons);
    } catch (_) {
      store.dispatch(FetchPersonsFailureAction());
    }
  }

  next(action);
}
