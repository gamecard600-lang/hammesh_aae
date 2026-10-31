import json
import re
import os
import sys

def clean_definition(d):
    # Remove '💡 અર્થ અને પરીક્ષાલક્ષી સંદર્ભ:' and everything after it
    d_clean = re.sub(r'[\s💡]*અર્થ અને પરીક્ષાલક્ષી સંદર્ભ:.*$', '', d, flags=re.DOTALL).strip()
    d_clean = re.sub(r'[\s💡]*Detailed Exam Context:.*$', '', d_clean, flags=re.DOTALL).strip()

    # Clean LaTeX if any broken fragments exist
    d_clean = d_clean.replace(r'\frac', '').replace(r'\int', '').replace(r'\rho', 'ρ')

    if ':' not in d_clean:
        parts = d_clean.split(' ', 1)
        if len(parts) == 2:
            d_clean = f'{parts[0]}: {parts[1]}'
        else:
            d_clean = f'{d_clean}: મૂળભૂત ટેકનિકલ વ્યાખ્યા.'

    # Split by colon and verify both sides
    colon_idx = d_clean.find(':')
    label = d_clean[:colon_idx].strip()
    desc = d_clean[colon_idx+1:].strip()
    if not label:
        label = 'Concept'
    if not desc:
        desc = 'મૂળભૂત સિદ્ધાંત અને ટેકનિકલ વ્યાખ્યા.'

    return f'{label}: {desc}'

def clean_list_items(items):
    cleaned = []
    for item in items:
        it = str(item).strip()
        if not it:
            continue
        # Drop filler / keyword lines
        if it.startswith('• MCQ કોન્સેપ્ટ') or it.startswith('• MCQ Concept'):
            continue
        if 'PDF Blueprint' in it or 'Detailed Exam Context' in it:
            continue
        if 'અર્થ અને પરીક્ષાલક્ષી સંદર્ભ' in it or 'GSSSB Audit' in it:
            continue

        # Clean broken LaTeX syntax
        it = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1 / \2)', it)
        it = it.replace(r'\rho', 'ρ').replace(r'\gamma', 'γ').replace(r'\eta', 'η').replace(r'\theta', 'θ')

        cleaned.append(it)
    return cleaned

def clean_theory_body(text):
    lines = text.split('\n')
    cleaned_lines = []
    skip = False

    for line in lines:
        l = line.strip()

        # Skip audit blocks and filler headers
        if '📌 PDF Blueprint Syllabus Scope:' in l or '📌 MCQ & Video Concept Coverage' in l:
            skip = True
            continue
        if '💡 વિગતે સમજૂતી અને પરીક્ષાલક્ષી સંકલન' in l or '🌟 વધારાનું પરીક્ષાલક્ષી મુદ્દો' in l:
            skip = True
            continue
        if l.startswith('• MCQ કોન્સેપ્ટ') or l.startswith('• MCQ Concept'):
            continue
        if l.startswith('- વ્યાખ્યા અને મૂળ અર્થ:') or l.startswith('- પ્રક્રિયા/ચક્ર/કાયદાનો હેતુ:'):
            continue
        if l.startswith('- મુખ્ય તબક્કાઓ અને કાર્યક્રમ:') or l.startswith('- વ્યવહારિક ફાયદા અને મર્યાદાઓ:'):
            continue
        if l.startswith('- GSSSB AAE પરીક્ષા ટિપ:'):
            continue

        # Re-enable line adding if a numbered section heading is reached
        if re.match(r'^[૧૨૩૪૫૬૭૮૯૦1-9]+\.\s+', l):
            skip = False

        if not skip and l:
            # Clean math LaTeX if present
            l_clean = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1 / \2)', l)
            l_clean = l_clean.replace(r'\rho', 'ρ').replace(r'\gamma', 'γ').replace(r'\eta', 'η').replace(r'\theta', 'θ')
            cleaned_lines.append(l_clean)

    return '\n'.join(cleaned_lines)

def build_mcq_concept_integration(qlist):
    if not qlist:
        return '', []

    concept_lines = []
    exam_point_lines = []

    for q in qlist:
        gq = q.get('gujaratiQuestion', q.get('question', '')).strip()
        gq = re.sub(r'^\d+[\.\)]\s*', '', gq).strip()

        opts = q.get('options', [])
        ans_idx = q.get('correctAnswer', 0)
        ans_text = opts[ans_idx].strip() if 0 <= ans_idx < len(opts) else ''

        exp = q.get('explanation', '').strip()
        exp = re.sub(r'\[cite:\s*\d+\]', '', exp)
        exp = re.sub(r'\s*\[Exam Source.*\]', '', exp, flags=re.DOTALL)
        exp = re.sub(r'\s*\[High Yield.*\]', '', exp, flags=re.DOTALL).strip()

        exp_first = exp.split('\n')[0].strip() if exp else ''

        if gq and ans_text:
            if exp_first:
                concept_lines.append(f'• {gq}: સાચો જવાબ -> {ans_text}. ({exp_first})')
            else:
                concept_lines.append(f'• {gq}: સાચો જવાબ -> {ans_text}.')

            exam_point_lines.append(f'🎯 MCQ Concept: {gq} ➔ {ans_text}')

    return '\n'.join(concept_lines[:12]), exam_point_lines[:8]

def main():
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

    processed_count = 0
    for subj_obj in master:
        subj_name = subj_obj['subject'].strip()
        for t_obj in subj_obj.get('topics', []):
            topic_name = t_obj['topic'].strip()

            # 1. Definitions
            raw_defs = t_obj.get('definitions', [])
            cleaned_defs = [clean_definition(d) for d in raw_defs]
            t_obj['definitions'] = cleaned_defs

            # 2. Detailed Theory
            raw_theory = t_obj.get('detailedTheory', '')
            base_theory = clean_theory_body(raw_theory)

            # 3. MCQ Integration
            topic_qs = questions_map.get((subj_name, topic_name), [])
            mcq_section_text, extra_exam_points = build_mcq_concept_integration(topic_qs)

            if mcq_section_text:
                full_theory = base_theory + '\n\n૯. GSSSB AAE Mechanical પરીક્ષાના મહત્વના તથ્યો અને MCQ સંકલન (GSSSB AAE Gold Exam Points):\n' + mcq_section_text
            else:
                full_theory = base_theory

            t_obj['detailedTheory'] = full_theory.strip()

            # 4. Clean Lists
            t_obj['keyPoints'] = clean_list_items(t_obj.get('keyPoints', []))
            t_obj['formulas'] = clean_list_items(t_obj.get('formulas', []))
            t_obj['solvedExamples'] = clean_list_items(t_obj.get('solvedExamples', []))
            t_obj['importantPoints'] = clean_list_items(t_obj.get('importantPoints', []))

            # Add extra MCQ exam points to examPoints
            existing_exam_pts = clean_list_items(t_obj.get('examPoints', []))
            for ep in extra_exam_points:
                if ep not in existing_exam_pts:
                    existing_exam_pts.append(ep)
            t_obj['examPoints'] = existing_exam_pts

            t_obj['commonMistakes'] = clean_list_items(t_obj.get('commonMistakes', []))
            t_obj['quickRevision'] = clean_list_items(t_obj.get('quickRevision', []))

            # Ensure mcqs and msqs are preserved
            t_obj['mcqs'] = t_obj.get('mcqs', [])
            t_obj['msqs'] = t_obj.get('msqs', [])

            processed_count += 1

    print(f'Processed {processed_count} topics across 14 subjects.')

    with open(master_path, 'w', encoding='utf-8') as f:
        json.dump(master, f, ensure_ascii=False, indent=2)

    print('Successfully updated master_study_material.json!')

if __name__ == '__main__':
    main()
