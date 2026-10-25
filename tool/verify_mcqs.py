import json,csv
from pathlib import Path
root=Path(__file__).resolve().parents[1]; out=root/'mcq_verification_report.csv'; rows=[]
for p in sorted((root/'assets/questions').glob('*.json')):
 if p.name=='subjects.json': continue
 d=json.loads(p.read_text(encoding='utf-8'))
 for q in d:
  e=[]; o=q.get('options',[]); a=q.get('correctAnswers') if isinstance(q.get('correctAnswers'),list) else [q.get('correctAnswer')]
  if not isinstance(q.get('id'),int) or q['id']<=0:e.append('invalid id')
  if not q.get('question'):e.append('missing question')
  if not isinstance(o,list) or len(o)<2:e.append('invalid options')
  if not a or any(not isinstance(x,int) or x<0 or x>=len(o) for x in a):e.append('invalid answer index')
  if not q.get('explanation'):e.append('missing explanation')
  rows.append([p.name,q.get('id'),'STRUCTURE_OK' if not e else 'STRUCTURE_ERROR','; '.join(e)])
with out.open('w',newline='',encoding='utf-8-sig') as f:
 w=csv.writer(f);w.writerow(['file','id','status','issues']);w.writerows(rows)
print('Questions Audited:',len(rows));print('Structural Errors:',sum(r[2]!='STRUCTURE_OK' for r in rows));print('Report:',out)
