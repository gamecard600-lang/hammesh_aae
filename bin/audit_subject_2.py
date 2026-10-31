import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

fluid_subject = data[1] # Subject 2: Fluid Mechanics
print(f"=======================================================")
print(f"AUDITING SUBJECT 2: {fluid_subject.get('subject')}")
print(f"=======================================================")

topics = fluid_subject.get('topics', [])
print(f"Total Topics in Subject 2: {len(topics)}\n")

for i, t in enumerate(topics):
    title = t.get('title', '')
    subtopics = t.get('subtopics', [])
    print(f"Topic {i+1}: {title} ({len(subtopics)} subtopics)")
    for st in subtopics[:3]:
        st_title = st.get('title', st.get('subtopicName', ''))
        print(f"   - Subtopic: {st_title}")

# Also check MCQs for Fluid Mechanics
q_file = 'assets/questions/fluid_mechanics.json'
if os.path.exists(q_file):
    q_data = json.load(open(q_file, encoding='utf-8'))
    print(f"\nTotal MCQs in {q_file}: {len(q_data)}")
