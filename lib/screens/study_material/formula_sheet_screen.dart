import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/formula.dart';
import '../../services/study_material_loader.dart';
import 'formula_flashcard_screen.dart';

class FormulaSheetScreen extends StatefulWidget {
  const FormulaSheetScreen({super.key});

  @override
  State<FormulaSheetScreen> createState() => _FormulaSheetScreenState();
}

class _FormulaSheetScreenState extends State<FormulaSheetScreen> {
  List<Formula> formulas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    final loaded = await StudyMaterialLoader.loadAllFormulas();
    if (!mounted) return;
    setState(() {
      formulas = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Sheet'),
        actions: [
          if (formulas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.style),
              tooltip: 'Switch to Flashcards',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormulaFlashcardScreen(formulas: formulas),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : formulas.isEmpty
              ? const Center(child: Text('No formulas available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: formulas.length,
                  itemBuilder: (context, index) {
                    final f = formulas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    f.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    f.subject,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Theme.of(context).dividerColor),
                                    ),
                                    child: Text(
                                      f.formula,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20, color: Colors.blue),
                                  tooltip: 'Copy Formula',
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: '${f.title}: ${f.formula}'));
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Formula copied to clipboard!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              f.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
