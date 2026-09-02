import 'package:flutter/material.dart';
import 'package:event_app/core/network/api_exceptions.dart';
import 'package:event_app/services/relative_service.dart';
import 'package:event_app/models/relative.dart';
import 'package:event_app/models/group_summary.dart';

class RelativeProvider extends ChangeNotifier {
  final RelativeService _relativeService;

  RelativeProvider(this._relativeService);

  bool _isLoading = false;
  String? _error;
  List<RelativeModel> _relatives = [];
  List<GroupSummary> _groupSummary = [];
  RelativeDetailModel? _selectedRelative;
  String? _filterGroupType;
  String? _searchQuery;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RelativeModel> get relatives => _relatives;
  List<GroupSummary> get groupSummary => _groupSummary;
  RelativeDetailModel? get selectedRelative => _selectedRelative;
  String? get filterGroupType => _filterGroupType;
  String? get searchQuery => _searchQuery;

  Future<void> loadRelatives() async {
    _setLoading(true);
    try {
      _relatives = await _relativeService.getRelatives(
        groupType: _filterGroupType,
        search: _searchQuery,
      );
      _setLoading(false);
    } catch (e) {
      _setError(apiErrorMessage(e));
    }
  }

  Future<void> loadGroupSummary() async {
    try {
      _groupSummary = await _relativeService.getGroupSummary();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load group summary: $e');
    }
  }

  Future<void> loadRelativeDetail(int id) async {
    _setLoading(true);
    try {
      _selectedRelative = await _relativeService.getDetail(id);
      _setLoading(false);
    } catch (e) {
      _setError(apiErrorMessage(e));
    }
  }

  Future<bool> createRelative(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _relativeService.create(data);
      _setLoading(false);
      await loadRelatives();
      await loadGroupSummary();
      return true;
    } catch (e) {
      _setError(apiErrorMessage(e));
      return false;
    }
  }

  Future<bool> updateRelative(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _relativeService.update(id, data);
      _setLoading(false);
      await loadRelatives();
      await loadGroupSummary();
      if (_selectedRelative != null && _selectedRelative!.id == id) {
        await loadRelativeDetail(id);
      }
      return true;
    } catch (e) {
      _setError(apiErrorMessage(e));
      return false;
    }
  }

  Future<bool> deleteRelative(int id) async {
    _setLoading(true);
    try {
      await _relativeService.delete(id);
      _relatives.removeWhere((r) => r.id == id);
      _setLoading(false);
      await loadGroupSummary();
      return true;
    } catch (e) {
      _setError(apiErrorMessage(e));
      return false;
    }
  }

  void setGroupFilter(String? groupType) {
    if (_filterGroupType != groupType) {
      _filterGroupType = groupType;
      notifyListeners();
      loadRelatives();
    }
  }

  void setSearchQuery(String? query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
      loadRelatives();
    }
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
