import json

file = open('assets/questions/thermodynamics.json', encoding='utf-8')
data = json.load(file)
mcqs = [q for q in data if q.get('subTopic') == 'Zeroth Law & Temperature']

print(f'Total MCQs for Zeroth Law & Temperature: {len(mcqs)}')
for i, q in enumerate(mcqs):
    gq = q.get('gujaratiQuestion', q.get('question', ''))
    opts = q.get('options', [])
    c_idx = q.get('correctAnswer', 0)
    ans = opts[c_idx] if c_idx < len(opts) else ''
    print(f"{i+1}. ID {q['id']}: {gq}")
    print(f"   Correct Answer: {ans}\n")
