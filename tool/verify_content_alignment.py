import json, glob, os, sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
subjects=json.loads((root/'assets/questions/subjects.json').read_text(encoding='utf-8'))
syll={s['name']:set(s['subTopics']) for s in subjects}
# Nontechnical expected structure
nt=json.loads((root/'assets/questions/nontechnical_syllabus.json').read_text(encoding='utf-8')) if (root/'assets/questions/nontechnical_syllabus.json').exists() else {}
errors=[]
for f in glob.glob(str(root/'assets/questions/*.json')):
    name=os.path.basename(f)
    if name in ('subjects.json','pyq_sources.json','nontechnical_syllabus.json'): continue
    data=json.loads(Path(f).read_text(encoding='utf-8'))
    if not isinstance(data,list) or not data: continue
    subject=data[0].get('subject','')
    allowed=syll.get(subject, set(nt.get(subject,[])))
    for q in data:
        if q.get('subject')!=subject: errors.append(f'{name}: subject mismatch id={q.get("id")}')
        if q.get('subTopic') not in allowed: errors.append(f'{name}: topic outside syllabus id={q.get("id")} topic={q.get("subTopic")}')
        if not q.get('options') or not q.get('explanation'): errors.append(f'{name}: incomplete question id={q.get("id")}')
master=json.loads((root/'assets/study_material/master_study_material.json').read_text(encoding='utf-8'))
for s in master:
    for t in s.get('topics',[]):
        if not t.get('definitions'): errors.append(f'{s["subject"]}/{t["topic"]}: missing definition')
print('ALIGNMENT ERRORS:',len(errors))
for e in errors[:100]: print(e)
sys.exit(1 if errors else 0)
