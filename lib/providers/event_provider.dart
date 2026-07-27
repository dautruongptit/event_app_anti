import 'package:flutter/material.dart';
import 'package:event_app/services/event_service.dart';
import 'package:event_app/models/event.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService;

  EventProvider(this._eventService);

  bool _isLoading = false;
  String? _error;
  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  EventModel? _selectedEvent;

  String? _filterType;
  int? _filterRelativeId;
  int? _filterMonth;
  int? _filterYear;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  EventModel? get selectedEvent => _selectedEvent;
  String? get filterType => _filterType;
  int? get filterRelativeId => _filterRelativeId;
  int? get filterMonth => _filterMonth;
  int? get filterYear => _filterYear;

  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      _events = await _eventService.getEvents(
        type: _filterType,
        relativeId: _filterRelativeId,
        month: _filterMonth,
        year: _filterYear,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUpcoming({int limit = 5}) async {
    _setLoading(true);
    try {
      _upcomingEvents = await _eventService.getUpcoming(limit: limit);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadEventById(int id) async {
    _setLoading(true);
    try {
      _selectedEvent = await _eventService.getById(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _eventService.create(data);
      _setLoading(false);
      await loadEvents();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateEvent(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _eventService.update(id, data);
      _setLoading(false);
      await loadEvents();
      if (_selectedEvent != null && _selectedEvent!.id == id) {
        await loadEventById(id);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteEvent(int id) async {
    _setLoading(true);
    try {
      await _eventService.delete(id);
      _events.removeWhere((e) => e.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void setFilter({String? type, int? relativeId, int? month, int? year}) {
    _filterType = type;
    _filterRelativeId = relativeId;
    _filterMonth = month;
    _filterYear = year;
    notifyListeners();
    loadEvents();
  }

  void clearFilters() {
    _filterType = null;
    _filterRelativeId = null;
    _filterMonth = null;
    _filterYear = null;
    notifyListeners();
    loadEvents();
  }

  void clearError() {
    _error = null;
    notifyListeners();
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
