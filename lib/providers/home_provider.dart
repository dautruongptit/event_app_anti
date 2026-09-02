import 'package:flutter/material.dart';
import 'package:event_app/core/network/api_exceptions.dart';
import 'package:event_app/services/home_service.dart';
import 'package:event_app/models/home_response.dart';
import 'package:event_app/models/event.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService;

  HomeProvider(this._homeService);

  bool _isLoading = false;
  String? _error;
  HomeResponse? _homeData;
  List<EventModel> _myEvents = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  HomeResponse? get homeData => _homeData;
  List<EventModel> get myEvents => _myEvents;

  Future<void> loadHomeData() async {
    _setLoading(true);
    try {
      _homeData = await _homeService.getHomeData();
      _setLoading(false);
    } catch (e) {
      _setError(apiErrorMessage(e));
    }
  }

  Future<void> loadMyEvents() async {
    _setLoading(true);
    try {
      _myEvents = await _homeService.getMyEvents();
      _setLoading(false);
    } catch (e) {
      _setError(apiErrorMessage(e));
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _homeService.getHomeData(),
        _homeService.getMyEvents(),
      ]);
      
      _homeData = futures[0] as HomeResponse?;
      _myEvents = (futures[1] as List).cast<EventModel>();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(apiErrorMessage(e));
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
