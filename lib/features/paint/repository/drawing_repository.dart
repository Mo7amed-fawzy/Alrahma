import 'dart:convert';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:alrahma/core/database/cache/app_preferences.dart';

class DrawingRepository {
  final AppPreferences drawingsPrefs;

  DrawingRepository({required this.drawingsPrefs});

  /// =======================
  /// CRUD Operations
  /// =======================

  // Get all drawings
  Future<List<DrawingModel>> getAll() async {
    return await drawingsPrefs.getModels(
      CacheKeys.drawingsKey,
      (j) => DrawingModel.fromJson(jsonEncode(j)),
    );
  }

  // Add a new drawing
  Future<void> add(DrawingModel drawing) async {
    final list = await getAll();
    list.add(drawing);
    await saveAll(list);
  }

  // Update a drawing by id
  Future<void> update(DrawingModel drawing) async {
    final list = await getAll();
    final updatedList = list
        .map((d) => d.id == drawing.id ? drawing : d)
        .toList();
    await saveAll(updatedList);
  }

  // Delete a drawing by id
  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((d) => d.id == id);
    await saveAll(list);
  }

  // Clear all drawings
  Future<void> clearAll() async {
    await drawingsPrefs.saveModels(
      CacheKeys.drawingsKey,
      <DrawingModel>[],
      (d) => d.toMap(),
    );
  }

  // Save list to storage
  Future<void> saveAll(List<DrawingModel> drawings) async {
    await drawingsPrefs.saveModels(
      CacheKeys.drawingsKey,
      drawings,
      (d) => d.toMap(),
    );
  }

  /// =======================
  /// JSON Export / Import
  /// =======================

  // Export a single drawing to JSON string
  String exportDrawingToJson(DrawingModel drawing) {
    return jsonEncode(drawing.toMap());
  }

  // Export all drawings to JSON string
  Future<String> exportAllDrawingsToJson() async {
    final list = await getAll();
    final jsonList = list.map((d) => d.toMap()).toList();
    return jsonEncode(jsonList);
  }

  // Import drawings from JSON string
  Future<void> importDrawingsFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    final drawings = decoded
        .map((j) => DrawingModel.fromJson(jsonEncode(j)))
        .toList();
    await saveAll(drawings);
  }
}
