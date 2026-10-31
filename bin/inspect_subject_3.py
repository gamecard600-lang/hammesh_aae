import json

data = json.load(open('assets/study_material/master_study_material.json', encoding='utf-8'))
subj3 = data[2]

print("=== SUBJECT 3 AUDIT ===")
print("Subject Name:", subj3.get('subject', subj3.get('subjectName')))
print("Total Topics:", len(subj3['topics']))

for i, t in enumerate(subj3['topics']):
    print(f"Topic {i+1}: {t['title']}")

# Check questions file
q_file = 'assets/questions/power_engineering.json'
try:
    q_data = json.load(open(q_file, encoding='utf-8'))
    print(f"\nTotal MCQs in {q_file}: {len(q_data)}")
except Exception as e:
    print(f"Error opening {q_file}: {e}")
