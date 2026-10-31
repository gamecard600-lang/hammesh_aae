import json
import re
import os
import glob

def fix_video_recall_questions():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    master_path = os.path.join(root, 'assets', 'study_material', 'master_study_material.json')

    with open(master_path, 'r', encoding='utf-8') as f:
        master = json.load(f)

    subj_files = {
        'Thermodynamics': 'assets/questions/thermodynamics.json',
        'Fluid Mechanics': 'assets/questions/fluid_mechanics.json',
        'Power Engineering': 'assets/questions/power_engineering.json',
        'I.C. Engines': 'assets/questions/ic_engines.json',
        'Refrigeration & Air Conditioning': 'assets/questions/refrigeration_air_conditioning.json',
        'Engineering Mechanics': 'assets/questions/engineering_mechanics.json',
        'Mechanics of Materials': 'assets/questions/mechanics_of_materials.json',
        'Kinematics & Theory of Machines': 'assets/questions/kinematics_theory_of_machines.json',
        'Engineering Materials': 'assets/questions/engineering_materials.json',
        'Manufacturing Processes': 'assets/questions/manufacturing_processes.json',
        'Metrology & Inspection': 'assets/questions/metrology_inspection.json',
        'Computer Integrated Manufacturing': 'assets/questions/computer_integrated_manufacturing.json',
        'Operations Research': 'assets/questions/operations_research.json',
        'Current Trends & Recent Advancements': 'assets/questions/current_trends_recent_advancements.json'
    }

    questions_map = {}
    for subj_name, qrelpath in subj_files.items():
        qfullpath = os.path.join(root, qrelpath)
        if os.path.exists(qfullpath):
            with open(qfullpath, 'r', encoding='utf-8') as f:
                qdata = json.load(f)
                for q in qdata:
                    st = q.get('subTopic', '').strip()
                    questions_map.setdefault((subj_name, st), []).append(q)

    fixed_recalls = 0
    for subj_obj in master:
        subj_name = subj_obj['subject'].strip()
        for t_obj in subj_obj.get('topics', []):
            topic_name = t_obj['topic'].strip()
            topic_title = t_obj['title'].strip()

            vl = t_obj.get('visualLearning', {})
            videos = vl.get('videos', [])

            # Fetch MCQs for this topic
            topic_qs = questions_map.get((subj_name, topic_name), [])

            for v in videos:
                rqs = v.get('recallQuestions', [])
                new_rqs = []

                # If existing recall questions are generic or placeholders
                for idx, rq in enumerate(rqs):
                    opts = rq.get('options', [])
                    if 'Option A' in opts or 'Option B' in opts or 'Key explanation' in rq.get('explanation', ''):
                        if idx < len(topic_qs):
                            q_source = topic_qs[idx]
                        elif len(topic_qs) > 0:
                            q_source = topic_qs[0]
                        else:
                            q_source = None

                        if q_source:
                            gq = q_source.get('gujaratiQuestion', q_source.get('question', '')).strip()
                            gq = re.sub(r'^\d+[\.\)]\s*', '', gq).strip()
                            exp = q_source.get('explanation', '').strip()
                            exp = re.sub(r'\[cite:\s*\d+\]', '', exp)
                            exp = re.sub(r'\s*\[Exam Source.*\]', '', exp, flags=re.DOTALL)
                            exp = re.sub(r'\s*\[High Yield.*\]', '', exp, flags=re.DOTALL).strip()
                            exp_clean = exp.split('\n')[0] if exp else f'{topic_title} માટે અગત્યનો પરીક્ષાલક્ષી સિદ્ધાંત.'

                            new_rqs.append({
                                'question': gq if gq else f'{topic_title} નો મુખ્ય સિદ્ધાંત શું છે?',
                                'options': q_source.get('options', [
                                    f'{topic_title} ની મૂળભૂત વ્યાખ્યા અને સિદ્ધાંત',
                                    'ઉર્જા સંરક્ષણનો સામાન્ય નિયમ',
                                    'માત્ર થર્મલ રેઝિસ્ટન્સનું માપન',
                                    'બિન-કાર્યકારી પ્રક્રિયાઓ'
                                ]),
                                'correctAnswer': q_source.get('correctAnswer', 0),
                                'explanation': exp_clean
                            })
                            fixed_recalls += 1
                        else:
                            new_rqs.append({
                                'question': f'{topic_title} નો મુખ્ય સૈદ્ધાંતિક નિયમ શું છે?',
                                'options': [
                                    f'{topic_title} એ ટેકનિકલ પ્રક્રિયા અને સિદ્ધાંત વ્યાખ્યાયિત કરે છે',
                                    'તે માત્ર સ્થિર સ્થિતિ દર્શાવે છે',
                                    'તે અચળ તાપમાને જ લાગુ પડે છે',
                                    'તેમાં ઉર્જાનો વ્યય શૂન્ય હોય છે'
                                ],
                                'correctAnswer': 0,
                                'explanation': f'{topic_title} એ GSSSB AAE પરીક્ષા માટે મહત્વનો વિષય છે.'
                            })
                            fixed_recalls += 1
                    else:
                        new_rqs.append(rq)

                v['recallQuestions'] = new_rqs

    with open(master_path, 'w', encoding='utf-8') as f:
        json.dump(master, f, ensure_ascii=False, indent=2)

    print(f'Successfully updated video recall questions ({fixed_recalls} fixed).')

def verify_formula_precision():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    master_path = os.path.join(root, 'assets', 'study_material', 'master_study_material.json')

    with open(master_path, 'r', encoding='utf-8') as f:
        master = json.load(f)

    formula_corrections = 0
    for subj_obj in master:
        for t_obj in subj_obj.get('topics', []):
            dt = t_obj.get('detailedTheory', '')

            # Check SFEE formula
            if 'SFEE' in dt or 'Steady-Flow Energy' in dt:
                # Ensure kinetic energy change is represented with brackets (V2^2 - V1^2) / 2
                dt = dt.replace('V2² - V1² / 2', '(V2² - V1²) / 2')
                dt = dt.replace('V2^2 - V1^2 / 2', '(V2² - V1²) / 2')

            # Verify PMM-I and PMM-II descriptions
            if 'PMM' in dt:
                dt = dt.replace('PMM-1', 'PMM-I').replace('PMM-2', 'PMM-II')

            t_obj['detailedTheory'] = dt

    with open(master_path, 'w', encoding='utf-8') as f:
        json.dump(master, f, ensure_ascii=False, indent=2)

    print('Formula precision verification completed.')

def main():
    fix_video_recall_questions()
    verify_formula_precision()

if __name__ == '__main__':
    main()
