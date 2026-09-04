import '../models/question.dart';
import 'local_storage_service.dart';
import 'question_service.dart';

class BookmarkService {
  static Future<List<Question>> loadBookmarks() async {
    final ids = await LocalStorageService.loadBookmarks();
    if (ids.isEmpty) return [];
    return await QuestionService.getQuestionsByIds(ids.toList());
  }

  static Future<void> toggleBookmark(Question question) async {
    final ids = await LocalStorageService.loadBookmarks();
    if (ids.contains(question.id)) {
      ids.remove(question.id);
    } else {
      ids.add(question.id);
    }
    await LocalStorageService.saveBookmarks(ids);
  }

  static Future<bool> isBookmarked(int questionId) async {
    final ids = await LocalStorageService.loadBookmarks();
    return ids.contains(questionId);
  }

  static Future<void> clearBookmarks() async {
    await LocalStorageService.saveBookmarks({});
  }
}
