import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/service_groups.dart';
import 'package:flutter_application_2/common/services/fetch_service_by_group_api.dart';


class FetchServiceGroupByController extends ChangeNotifier {
 final FetchServiceByGroupApi api =FetchServiceByGroupApi();



  List<ServiceGroupModel> _groups = [];
  List<ServiceGroupModel> get groups => _groups;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Fetch service groups from API
  Future<void> fetchGroups() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await FetchServiceByGroupApi.fetchServiceGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}