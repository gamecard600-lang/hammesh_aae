import 'package:flutter/material.dart';
import 'dart:math';

import '../data/subjects.dart';
import '../models/question.dart';
import '../models/practice_mode.dart';
import '../services/question_service.dart';
import 'question_practice_screen.dart';

class MockTestSetupScreen extends StatefulWidget {
  const MockTestSetupScreen({super.key});

  @override
  State<MockTestSetupScreen> createState() => _MockTestSetupScreenState();
}

class _MockTestSetupScreenState extends State<MockTestSetupScreen> {
  final Set<String> selectedSubjectNames = technicalSubjects.map((s) => s.name).toSet();
  int questionLimit = 100;
  int durationMinutes = 60;
  bool negativeMarking = true;
  bool isLoading = false;

  final List<int> limitOptions = [25, 50, 100, 150, 200];
  final List<int> durationOptions = [30, 45, 60, 90, 120];

  void _toggleSubject(String name) {
    setState(() {
      if (selectedSubjectNames.contains(name)) {
        selectedSubjectNames.remove(name);
      } else {
        selectedSubjectNames.add(name);
      }
    });
  }

  void _selectAll(bool select) {
    setState(() {
      if (select) {
        selectedSubjectNames.addAll(technicalSubjects.map((s) => s.name));
      } else {
        selectedSubjectNames.clear();
      }
    });
  }

  List<Question> _selectBalancedQuestions(Map<String, List<Question>> subjectMap, int totalNeeded) {
    final List<Question> result = [];
    if (subjectMap.isEmpty) return result;

    final Map<String, List<Question>> pools = {};
    subjectMap.forEach((key, value) {
      pools[key] = List.from(value)..shuffle();
    });

    int remaining = totalNeeded;
    List<String> activeSubjects = pools.keys.toList();

    while (remaining > 0 && activeSubjects.isNotEmpty) {
      int perSubject = (remaining / activeSubjects.length).ceil();
      List<String> toRemove = [];

      for (String sub in activeSubjects) {
        final pool = pools[sub]!;
        int take = min(perSubject, pool.length);
        take = min(take, remaining);

        result.addAll(pool.take(take));
        pool.removeRange(0, take);
        remaining -= take;

        if (pool.isEmpty) toRemove.add(sub);
        if (remaining <= 0) break;
      }
      activeSubjects.removeWhere((s) => toRemove.contains(s));
    }

    result.shuffle();
    return result;
  }

  Future<void> _startMockTest() async {
    if (selectedSubjectNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને ઓછામાં ઓછું એક Subject પસંદ કરો.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final Map<String, List<Question>> subjectMap = {};
      for (final name in selectedSubjectNames) {
        final qs = await QuestionService.loadQuestionsBySubject(name);
        if (qs.isNotEmpty) subjectMap[name] = qs;
      }

      if (subjectMap.isEmpty) {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('પસંદ કરેલા Subjects માટે પ્રશ્નો મળ્યા નથી.')),
        );
        return;
      }

      final totalAvailable = subjectMap.values.fold(0, (sum, list) => sum + list.length);
      
      if (totalAvailable < questionLimit) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ઓછા પ્રશ્નો ઉપલબ્ધ છે'),
            content: Text('તમે $questionLimit પ્રશ્નો પસંદ કર્યા છે, પરંતુ માત્ર $totalAvailable ઉપલબ્ધ છે. શું તમે $totalAvailable પ્રશ્નો સાથે ટેસ્ટ શરૂ કરવા માંગો છો?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ના')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('હા')),
            ],
          ),
        );
        if (proceed != true) {
          setState(() => isLoading = false);
          return;
        }
      }

      final finalQuestions = _selectBalancedQuestions(subjectMap, questionLimit);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionPracticeScreen(
            questions: finalQuestions,
            subject: 'Mock Test',
            config: PracticeConfig(
              mode: PracticeMode.mockTest,
              timerEnabled: true,
              negativeMarking: negativeMarking,
              instantResult: false,
              questionLimit: null, // Already limited by _selectBalancedQuestions
              durationMinutes: durationMinutes,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  int testTypeIndex = 2; // Default to Full AAE Test (100 Qs)

  void _applyTestType(int index) {
    setState(() {
      testTypeIndex = index;
      if (index == 0) {
        questionLimit = 25;
        durationMinutes = 30;
      } else if (index == 1) {
        questionLimit = 50;
        durationMinutes = 60;
      } else if (index == 2) {
        questionLimit = 100;
        durationMinutes = 120;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('મોક ટેસ્ટ સેટઅપ'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'ટેસ્ટ પ્રકાર પસંદ કરો',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildTestTypeCard(0, 'ઝડપી ટેસ્ટ', '25 પ્રશ્નો • 30 મિનિટ', Icons.flash_on, Colors.red),
                      _buildTestTypeCard(1, 'વિષય ટેસ્ટ', '50 પ્રશ્નો • 60 મિનિટ', Icons.my_library_books, Colors.orange),
                      _buildTestTypeCard(2, 'AAE પૂરી લંબાઈ ટેસ્ટ', '100 પ્રશ્નો • 120 મિનિટ', Icons.military_tech, Colors.blue),
                      _buildTestTypeCard(3, 'કસ્ટમ ટેસ્ટ', 'તમારી પસંદગી મુજબ સેટિંગ્સ', Icons.tune, Colors.teal),
                      const SizedBox(height: 20),
                      if (testTypeIndex == 3) ...[
                        const Text(
                          'વિષયો પસંદ કરો:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(onPressed: () => _selectAll(true), child: const Text('બધા પસંદ કરો')),
                            TextButton(onPressed: () => _selectAll(false), child: const Text('ક્લીયર કરો')),
                          ],
                        ),
                        ...technicalSubjects.map((subject) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(subject.name),
                            value: selectedSubjectNames.contains(subject.name),
                            onChanged: (_) => _toggleSubject(subject.name),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'કસોટી સેટિંગ્સ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            if (testTypeIndex == 3) ...[
                              _buildSettingRow(
                                'પ્રશ્નોની સંખ્યા',
                                DropdownButton<int>(
                                  value: questionLimit,
                                  items: limitOptions.map((opt) => DropdownMenuItem(value: opt, child: Text('$opt'))).toList(),
                                  onChanged: (val) { if (val != null) setState(() => questionLimit = val); },
                                ),
                              ),
                              const Divider(height: 0),
                              _buildSettingRow(
                                'સમયગાળો (મિનિટ)',
                                DropdownButton<int>(
                                  value: durationMinutes,
                                  items: durationOptions.map((opt) => DropdownMenuItem(value: opt, child: Text('$opt min'))).toList(),
                                  onChanged: (val) { if (val != null) setState(() => durationMinutes = val); },
                                ),
                              ),
                              const Divider(height: 0),
                            ],
                            _buildSettingRow(
                              'નેગેટિવ માર્કિંગ (-0.25)',
                              Switch(
                                value: negativeMarking,
                                onChanged: (val) => setState(() => negativeMarking = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startMockTest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'ટેસ્ટ શરૂ કરો',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTestTypeCard(int index, String title, String subtitle, IconData icon, Color color) {
    final isSelected = testTypeIndex == index;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
      ),
      child: ListTile(
        onTap: () => _applyTestType(index),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
