import 'package:flutter/foundation.dart';
import '../../models/project_model.dart';
import '../../repositories/project_repository.dart';
import 'dart:math';

class ProjectController extends ChangeNotifier {
  final ProjectRepository _repository;

  List<ProjectModel> projects = [];
  bool isLoading = false;
  String? errorMessage;

  ProjectController(this._repository);

  Future<void> fetchProjects() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      projects = await _repository.getProjects();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject(String lecturerId, String title, String description, String? submissionInfo) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final joinCode = _generateJoinCode();
      final newProject = ProjectModel(
        joinCode: joinCode,
        lecturerId: lecturerId,
        title: title,
        description: description,
        finalSubmissionInfo: submissionInfo,
        createdAt: DateTime.now(),
      );

      final createdProject = await _repository.createProject(newProject);
      projects.add(createdProject);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(String joinCode, {String? title, String? description, String? submissionInfo}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (submissionInfo != null) data['final_submission_info'] = submissionInfo;

      await _repository.updateProject(joinCode, data);
      await fetchProjects();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeProject(String joinCode) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.closeProject(joinCode);
      final index = projects.indexWhere((p) => p.joinCode == joinCode);
      if (index != -1) {
        projects[index] = ProjectModel(
          joinCode: projects[index].joinCode,
          lecturerId: projects[index].lecturerId,
          title: projects[index].title,
          description: projects[index].description,
          finalSubmissionInfo: projects[index].finalSubmissionInfo,
          isActive: false,
          createdAt: projects[index].createdAt,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
