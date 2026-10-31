import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

for subj_idx in [2, 3]: # Subject 3: Power Engineering, Subject 4: IC Engines
    s = data[subj_idx]
    s_name = s.get('subject')
    topics = s.get('topics', [])
    print(f"=======================================================")
    print(f"SUBJECT {subj_idx+1}: {s_name} ({len(topics)} topics)")
    print(f"=======================================================")
    for i, t in enumerate(topics):
        print(f"  Topic {i+1}: {t.get('title')}")
    print()
