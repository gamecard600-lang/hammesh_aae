import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

fluid_subject = data[1] # Subject 2: Fluid Mechanics
topics = fluid_subject.get('topics', [])
print(f"Subject Name: {fluid_subject.get('subject')}")
print(f"Total Topics in Subject 2: {len(topics)}\n")

for i, t in enumerate(topics):
    title = t.get('title', '')
    vl = t.get('visualLearning', {})
    videos = vl.get('videos', [])
    asset_path = videos[0].get('assetPath', 'None') if videos else 'None'
    print(f"Topic {i+1}: {title}")
    print(f"   Asset Path: {asset_path}\n")
