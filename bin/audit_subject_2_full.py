import os
import json

file_path = 'assets/questions/subjects.json'
if os.path.exists(file_path):
    subjects = json.load(open(file_path, encoding='utf-8'))
    print("=== SUBJECTS IN ASSETS/QUESTIONS/SUBJECTS.JSON ===")
    for s in subjects:
        print(f"ID {s.get('id')}: {s.get('name')} ({s.get('totalTopics', 0)} topics, {s.get('questionCount', 0)} MCQs)")

print("\n=== QUESTION FILES IN ASSETS/QUESTIONS/ ===")
q_files = [f for f in os.listdir('assets/questions/') if f.endswith('.json')]
for qf in sorted(q_files):
    data = json.load(open(os.path.join('assets/questions/', qf), encoding='utf-8'))
    if isinstance(data, list):
        print(f"{qf}: {len(data)} MCQs")
