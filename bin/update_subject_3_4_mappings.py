import json

file_path = 'assets/study_material/master_study_material.json'
data = json.load(open(file_path, encoding='utf-8'))

# Subject 3: Power Engineering (data[2])
power_subj = data[2]
power_topics = power_subj.get('topics', [])
p_mappings = [
    'air_compressors.mp4',          # Topic 1: Air Compressors
    'vapor_power_cycles.mp4',       # Topic 2: Vapor Power Cycles
    'vapor_power_cycles.mp4',       # Topic 3: Regeneration
    'air_compressors.mp4',          # Topic 4: Compressor Classification
    'air_compressors.mp4',          # Topic 5: Gas Compressors
    'gas_power_cycles.mp4',         # Topic 6: Gas Power Cycles
    'vapor_power_cycles.mp4',       # Topic 7: Reheat
    'gas_power_cycles.mp4'          # Topic 8: Thermal Efficiency Concepts
]

for i, t in enumerate(power_topics):
    if i < len(p_mappings):
        mp4_path = f"assets/videos/{p_mappings[i]}"
        vl = t.get('visualLearning', {})
        videos = vl.get('videos', [])
        if videos:
            videos[0]['assetPath'] = mp4_path
        else:
            t['visualLearning'] = {
                'videos': [{'title': f"{t.get('title')} Video Lesson", 'assetPath': mp4_path}]
            }
        print(f"✅ Subject 3 Topic {i+1} ({t.get('title')}): Mapped to {mp4_path}")

# Subject 4: IC Engines (data[3])
ic_subj = data[3]
ic_topics = ic_subj.get('topics', [])
ic_mappings = [
    'ic_engine_combustion_knocking.mp4', # Topic 1: Combustion Process
    'ic_engine_combustion_knocking.mp4', # Topic 2: Knocking
    'fuel_systems_and_crdi.mp4',        # Topic 3: Fuel Injection
    'engine_systems_emissions.mp4',     # Topic 4: Engine Systems
    'engine_systems_emissions.mp4',     # Topic 5: Emissions
    'engine_systems_emissions.mp4',     # Topic 6: Advanced Concepts
    'construction_heavy_equipment.mp4', # Topic 7: Construction Equipment
    'ic_engine_combustion_knocking.mp4', # Topic 8: Combustion Chambers
    'fuel_systems_and_crdi.mp4',        # Topic 9: Fuel Systems
    'fuel_systems_and_crdi.mp4',        # Topic 10: CRDI
    'air_standard_cycles.mp4',          # Topic 11: Performance
    'air_standard_cycles.mp4',          # Topic 12: Air-Standard Cycles
    'construction_heavy_equipment.mp4'  # Topic 13: Heavy Equipment
]

for i, t in enumerate(ic_topics):
    if i < len(ic_mappings):
        mp4_path = f"assets/videos/{ic_mappings[i]}"
        vl = t.get('visualLearning', {})
        videos = vl.get('videos', [])
        if videos:
            videos[0]['assetPath'] = mp4_path
        else:
            t['visualLearning'] = {
                'videos': [{'title': f"{t.get('title')} Video Lesson", 'assetPath': mp4_path}]
            }
        print(f"✅ Subject 4 Topic {i+1} ({t.get('title')}): Mapped to {mp4_path}")

json.dump(data, open(file_path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print("\n🎉 MASTER STUDY MATERIAL SUCCESSFULLY UPDATED FOR SUBJECT 3 & 4!")
