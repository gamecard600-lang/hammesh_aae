import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/practice_mode.dart';
import '../services/bookmark_service.dart';
import 'review_screen.dart';
import 'question_practice_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Question> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final data = await BookmarkService.loadBookmarks();
    setState(() {
      bookmarks = data;
      isLoading = false;
    });
  }

  void _startBookmarkPractice() {
    if (bookmarks.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: bookmarks,
          subject: 'Bookmarks',
          config: PracticeConfig.bookmarkPractice,
        ),
      ),
    ).then((_) => _loadBookmarks()); // Refresh after practice
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        actions: [
          if (bookmarks.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
              tooltip: 'Practice Bookmarks',
              onPressed: _startBookmarkPractice,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All?'),
                    content: const Text('Do you want to remove all bookmarks?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await BookmarkService.clearBookmarks();
                  _loadBookmarks();
                }
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.isEmpty
              ? const Center(
                  child: Text(
                    'No bookmarks yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final question = bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          question.question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${question.subject} > ${question.subTopic}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Show in a review-like mode
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                questions: [question],
                                selectedAnswers: const [null],
                                selectedMSQAnswers: const [[]],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
