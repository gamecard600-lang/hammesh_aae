import json,re,sys
p='assets/study_material/master_study_material.json'
d=json.load(open(p,encoding='utf-8'))
assert len(d)==14, f'Expected 14 subjects, found {len(d)}'
count=0; bad=[]
for s in d:
    for t in s.get('topics',[]):
        for x in t.get('definitions',[]):
            count+=1
            if ':' not in x or not x.split(':',1)[0].strip() or not x.split(':',1)[1].strip():
                bad.append((s['subject'],t['topic'],x))
            # detect the old bare-label pattern
            if ':' not in x and re.fullmatch(r'[A-Za-z0-9 .&()\-_/\'’]+',x.strip()):
                bad.append((s['subject'],t['topic'],x))
print(f'Subjects: {len(d)}')
print(f'Topics: {sum(len(s.get("topics",[])) for s in d)}')
print(f'Definitions: {count}')
if bad:
    print('BAD DEFINITIONS:',len(bad))
    for b in bad[:20]: print(b)
    sys.exit(1)
print('DEFINITIONS VALIDATION: PASS')
